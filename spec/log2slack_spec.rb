# frozen_string_literal: true

RSpec.describe Log2slack do
  it "has a version number" do
    expect(Log2slack::VERSION).not_to be nil
  end
end

RSpec.describe Log2slack::Logger do
  describe "logging functionality" do
    it "initializes with default values" do
      logger = Log2slack::Logger.new
      expect(logger.messages).to eq([])
      expect(logger.status).to eq(Log2slack::Logger::LOG_LEVEL_INFO)
    end

    it "does not store messages without notify flag" do
      logger = Log2slack::Logger.new
      logger.info('test message')
      expect(logger.messages).to eq([])
    end

    it "stores messages with notify flag" do
      logger = Log2slack::Logger.new
      logger.info('info test', notify: true)
      expect(logger.messages).to eq(["[INFO]info test"])
    end

    it "updates status based on log level" do
      logger = Log2slack::Logger.new
      
      # Initial status is INFO
      expect(logger.status).to eq(Log2slack::Logger::LOG_LEVEL_INFO)
      
      # WARN updates status
      logger.warn('warn test', notify: true)
      expect(logger.status).to eq(Log2slack::Logger::LOG_LEVEL_WARN)
      
      # ERROR updates status
      logger.error('error test', notify: true)
      expect(logger.status).to eq(Log2slack::Logger::LOG_LEVEL_ERROR)
      
      # INFO does not overwrite ERROR status
      logger.info('info test', notify: true)
      expect(logger.status).to eq(Log2slack::Logger::LOG_LEVEL_ERROR)
      
      # WARN does not overwrite ERROR status
      logger.warn('another warn', notify: true)
      expect(logger.status).to eq(Log2slack::Logger::LOG_LEVEL_ERROR)
    end

    it "accumulates messages in order" do
      logger = Log2slack::Logger.new
      logger.info('first', notify: true)
      logger.warn('second', notify: true)
      logger.error('third', notify: true)
      
      expect(logger.messages).to eq([
        "[INFO]first",
        "[WARN]second",
        "[ERROR]third"
      ])
    end
  end

  describe "slack notification" do
    let(:logger) { Log2slack::Logger.new }
    let(:webhook_url) { "https://hooks.slack.com/services/xxx/yyy/zzz" }
    let(:channel) { "#general" }
    let(:user_name) { "Test User" }
    let(:title) { "Test Title" }

    before do
      # Reset the notifier before each test
      logger.instance_variable_set(:@notifier, nil)
    end

    it "sends notification to slack" do
      notifier_mock = instance_double("Slack::Notifier")
      expect(Slack::Notifier).to receive(:new).with(
        webhook_url, { channel: channel, username: user_name }
      ).and_return(notifier_mock)
      
      expect(notifier_mock).to receive(:post)
      
      logger.info('info test', notify: true)
      logger.notify_to_slack(webhook_url, channel, user_name, title)
    end

    it "formats title with channel mention for warnings" do
      logger.warn('warning message', notify: true)
      
      # Check that format_title adds channel mention
      expect(logger.format_title(title)).to eq("<!channel> #{title}")
    end

    it "formats title with channel mention for errors" do
      logger.error('error message', notify: true)
      
      # Check that format_title adds channel mention
      expect(logger.format_title(title)).to eq("<!channel> #{title}")
    end

    it "uses correct color based on status" do
      # INFO status
      expect(logger.status_color).to eq("good")
      
      # WARN status
      logger.warn('warning', notify: true)
      expect(logger.status_color).to eq("warning")
      
      # ERROR status
      logger.error('error', notify: true)
      expect(logger.status_color).to eq("danger")
    end

    it "uses custom payload when block is given" do
      notifier_mock = instance_double("Slack::Notifier")
      expect(Slack::Notifier).to receive(:new).and_return(notifier_mock)
      
      custom_payload = { text: "Custom message" }
      expect(notifier_mock).to receive(:post).with(custom_payload)
      
      logger.notify_to_slack(webhook_url, channel, user_name, title) do
        custom_payload
      end
    end

    it "handles errors during slack notification" do
      notifier_mock = instance_double("Slack::Notifier")
      expect(Slack::Notifier).to receive(:new).and_return(notifier_mock)
      expect(notifier_mock).to receive(:post).and_raise(StandardError.new("Connection error"))
      
      logger.info('info test', notify: true)
      expect {
        logger.notify_to_slack(webhook_url, channel, user_name, title)
      }.to raise_error(Log2slack::Error, /Slack notification failed/)
    end
  end
end
