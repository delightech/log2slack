# frozen_string_literal: true

require 'logger'
require 'slack-notifier'
module Log2slack
  class Logger
    # Log level constants
    LOG_LEVEL_INFO = 'INFO'
    LOG_LEVEL_WARN = 'WARN'
    LOG_LEVEL_ERROR = 'ERROR'

    attr_reader :messages, :status

    # Initialize a new Logger instance
    #
    # @param output [IO, String] The log output destination (STDOUT, file path, etc.)
    # @param max_files [Integer] Maximum number of log files to keep
    # @param max_size [Integer] Maximum size of each log file in bytes
    # @return [Logger] A new Logger instance
    def initialize(output = STDOUT, max_files = 10, max_size = 1024 * 1024)
      # load logger module
      @logger = ::Logger.new(output, max_files, max_size)
      @messages = []
      @status = LOG_LEVEL_INFO
    end

    # Log a message with the specified level
    #
    # @param message [String] The message to log
    # @param level [Symbol] The log level (:info, :warn, :error)
    # @param notify [Boolean] Whether to store the message for Slack notification
    # @return [void]
    def log(message, level: :info, notify: false)
      @logger.send(level, message)
      @messages.push("[#{level.to_s.upcase}]#{message}") if notify
      @status = level.to_s.upcase if level == :error
      # Do not overwrite with warn in case of error
      @status = level.to_s.upcase if level == :warn && @status != LOG_LEVEL_ERROR
    end

    # Log a message with INFO level
    #
    # @param message [String] The message to log
    # @param notify [Boolean] Whether to store the message for Slack notification
    # @return [void]
    def info(message, notify: false)
      log(message, level: :info, notify: notify)
    end

    # Log a message with WARN level
    #
    # @param message [String] The message to log
    # @param notify [Boolean] Whether to store the message for Slack notification
    # @return [void]
    def warn(message, notify: false)
      log(message, level: :warn, notify: notify)
    end

    # Log a message with ERROR level
    #
    # @param message [String] The message to log
    # @param notify [Boolean] Whether to store the message for Slack notification
    # @return [void]
    def error(message, notify: false)
      log(message, level: :error, notify: notify)
    end

    # Create attachment payload for Slack notification
    #
    # @param title [String] The title for the Slack message
    # @return [Hash] The attachment payload
    def make_attachments(title)
      { attachments: [
        {
          fallback: format_title(title),
          title: format_title(title),
          text: @messages.join("\n"),
          color: status_color
        }
      ] }
    end

    # Format the title based on the current status
    #
    # @param title [String] The original title
    # @return [String] The formatted title
    def format_title(title)
      if @status == LOG_LEVEL_ERROR || @status == LOG_LEVEL_WARN
        "<!channel> #{title}"
      else
        title
      end
    end

    # Determine the color based on the current status
    #
    # @return [String] The color code for Slack attachment
    def status_color
      case @status
      when LOG_LEVEL_ERROR
        'danger'
      when LOG_LEVEL_WARN
        'warning'
      else
        'good'
      end
    end

    # Send notification to Slack
    #
    # @param webhook_url [String] The Slack webhook URL
    # @param channel [String] The Slack channel to post to
    # @param user_name [String] The username to display in Slack
    # @param title [String] The title for the Slack message
    # @yield [optional] Block to provide custom payload
    # @return [void]
    # @raise [Log2slack::Error] If the Slack notification fails
    def notify_to_slack(webhook_url, channel, user_name, title)
      args = if block_given?
               yield()
             else
               make_attachments(title)
             end
      if @notifier.nil?
        @notifier = Slack::Notifier.new(
          webhook_url,
          channel: channel,
          username: user_name
        )
      end

      begin
        @notifier.post(args)
      rescue StandardError => e
        @logger.error("Failed to send notification to Slack: #{e.message}")
        raise Log2slack::Error, "Slack notification failed: #{e.message}"
      end
    end
  end
end
