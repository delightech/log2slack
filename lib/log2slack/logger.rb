# frozen_string_literal: true

require 'logger'
module Log
  class LogManager
    attr_reader :messages, :status
    def initialize
      @logger = Logger.new(STDOUT)
      @messages = []
      @status = 'INFO'
    end

    # TODO ログ通知にタイムスタンプ入れたい
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

    def aaa
      # TODO messagesを改行でJOINしてSlack通知をブロックで渡せるようにする
    end
  end
end
