# frozen_string_literal: true

require 'logger'
require 'slack-notifier'
module Log2slack
  class Logger
    attr_reader :messages, :status
    def initialize
      # load logger module
      @logger = ::Logger.new(STDOUT)
      @messages = []
      @status = 'INFO'
    end

    def log(message, level: :info, notify: false)
      @logger.send(level, message)
      @messages.push("[#{level.to_s.upcase}]#{message}") if notify
      @status = level.to_s.upcase if level == :error
      # Do not overwrite with warn in case of error
      @status = level.to_s.upcase if level == :warn && @status != 'ERROR'
    end

    def info(message, notify: false)
      log(message, level: :info, notify: notify)
    end

    def warn(message, notify: false)
      log(message, level: :warn, notify: notify)
    end

    def error(message, notify: false)
      log(message, level: :error, notify: notify)
    end

    def notify_to_slack(webhook_url, channel, user_name, title)
      message = @messages.join("\n")
      if @status == 'ERROR'
        title = "<!channel> #{title}"
        color = 'danger'
      elsif @status == 'WARN'
        title = "<!channel> #{title}"
        color = 'warning'
      else
        color = 'good'
      end
      attachments = {
        fallback: title,
        title: title,
        text: message,
        color: color
      }
      Slack::Notifier.new(
        webhook_url,
        channel: channel,
        username: user_name
      ).post(attachments: attachments)
    end
  end
end
