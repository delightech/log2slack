# frozen_string_literal: true

RSpec.describe Log2slack do
  it "has a version number" do
    expect(Log2slack::VERSION).not_to be nil
  end

  it "does something useful" do
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
end
