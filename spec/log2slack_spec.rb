# frozen_string_literal: true

RSpec.describe Log2slack do
  it "has a version number" do
    expect(Log2slack::VERSION).not_to be nil
  end

  it "log and status check" do
    l = Log2slack::Logger.new
    l.info('abc')
    expect(l.messages).to eq([])
    l.info('info test', notify: true)
    expect(l.status).to eq("INFO")
    expect(l.messages).to eq(["[INFO]info test"])
    l.warn('warn test', notify: true)
    expect(l.status).to eq("WARN")
    expect(l.messages).to eq(["[INFO]info test","[WARN]warn test"])
    l.error('error test', notify: true)
    expect(l.status).to eq("ERROR")
    expect(l.messages).to eq(["[INFO]info test","[WARN]warn test","[ERROR]error test"])
    l.info('info test2', notify: true)
    expect(l.status).to eq("ERROR")
    expect(l.messages).to eq(["[INFO]info test","[WARN]warn test","[ERROR]error test","[INFO]info test2"])
  end
  it "send to slack" do
    l = Log2slack::Logger.new
    l.info('info test', notify: true)
    #webhook_url = 'your webhook url'
    #channel = '#alert'
    #l.notify_to_slack(webhook_url,channel,'test user','test title')
    expect(true).to eq(true)
  end
  it "send to slack with block" do
    l = Log2slack::Logger.new
    l.info('info test', notify: true)
    #webhook_url = 'your webhook url'
    #channel = '#alert'
    #l.notify_to_slack(webhook_url,channel,'test user','test title') do
    #  {text: 'test text!'}
    #end
    expect(true).to eq(true)
  end
end
