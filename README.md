# Log2slack

[![Gem Version](https://badge.fury.io/rb/log2slack.svg)](https://badge.fury.io/rb/log2slack)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

Log2slack is a simple Ruby gem for recording application log messages and notifying them to Slack. It allows you to easily send logs generated from batch processes, web applications, and other systems to Slack channels.

## Features

- Support for standard log levels (INFO, WARN, ERROR)
- Automatic appearance changes based on log level
  - INFO: Green color
  - WARN: Yellow color + channel notification
  - ERROR: Red color + channel notification
- Custom notification format support
- Simple and easy-to-use API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'log2slack'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install log2slack
```

## Usage

### Basic Usage

```ruby
require 'log2slack'

# Initialize the logger
logger = Log2slack::Logger.new

# Record logs
# Normal logs (not notified to Slack)
logger.info("Process started")
logger.warn("Warning occurred")
logger.error("Error occurred")

# Record logs for Slack notification (specify notify: true)
logger.info("Process started", notify: true)
logger.warn("Warning occurred", notify: true)
logger.error("Error occurred", notify: true)

# Notify to Slack
webhook_url = "https://hooks.slack.com/services/xxx/yyy/zzz"
channel = "#general"
user_name = "Log Notifier"
title = "Batch Process Result"

logger.notify_to_slack(webhook_url, channel, user_name, title)
```

### Custom Notification Format

You can also notify Slack with a custom format using a block:

```ruby
logger.notify_to_slack(webhook_url, channel, user_name, title) do
  {
    text: "Custom text",
    attachments: [
      {
        title: "Detailed Information",
        text: "Detailed description here",
        color: "#36a64f"
      }
    ]
  }
end
```

### Log Levels and Notification Appearance

The appearance of Slack notifications automatically changes based on the log level:

- **INFO**: Green attachment
- **WARN**: Yellow attachment + channel notification (`<!channel>`)
- **ERROR**: Red attachment + channel notification (`<!channel>`)

Once an ERROR level log is recorded, the status will not be overwritten by subsequent INFO or WARN level logs. This prevents important error messages from being missed.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/delightech/log2slack. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Log2slack project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
