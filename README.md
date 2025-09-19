# Accounts

A Ruby gem that provides custom account management, push notifications, and authentication overrides for Mastodon-based social media platforms.

This gem extends Mastodon functionality with custom features for account creation, password management, notification tokens, and platform-specific behaviors for Newsmast and related social media instances.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'accounts', git: 'https://github.com/patchwork-hub/accounts.git'
```

And then execute:

```bash
bundle install
```

## Features

- **Custom Account Management**: Enhanced account creation and management for Mastodon instances
- **Push Notification Tokens**: Firebase notification token management for mobile apps
- **Custom Password Management**: Extended password reset and confirmation functionality
- **Platform Detection**: Helper methods to identify Newsmast and related platform instances
- **Authentication Overrides**: Custom OAuth behavior and Devise extensions
- **Email Settings**: API endpoints for managing user email preferences

## Usage

After installation, the gem automatically configures itself through Rails initializers. It extends existing Mastodon controllers and models with additional functionality.


### Notification Tokens

The gem provides API endpoints for managing push notification tokens:

```
POST /api/v1/notification_tokens
DELETE /api/v1/notification_tokens/:id
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/patchwork-hub/accounts. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/patchwork-hub/accounts/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [AGPL-3.0 License](https://opensource.org/licenses/AGPL-3.0).

## Code of Conduct

Everyone interacting in the Accounts project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/patchwork-hub/accounts/blob/main/CODE_OF_CONDUCT.md).
