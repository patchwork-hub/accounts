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

### Account Management
- **Custom Account Creation**: Enhanced account creation with community admin integration
- **Auto-Follow**: Automatically follow default accounts on signup (configurable via `AUTO_FOLLOW_ACCOUNTS` env var)
- **Server Settings**: Automatic search opt-in/opt-out and Bluesky bridge configuration for new users
- **Extended Credentials**: Account credentials API includes email in response

### Push Notifications
- **Firebase Cloud Messaging (FCM)**: Full integration for iOS and Android push notifications
- **Token Management**: Create, revoke, and manage notification tokens per device
- **Mute Control**: Per-account mute status for notifications
- **Multi-Platform Support**: Support for iOS, Android, and Huawei devices
- **Rich Notifications**: Custom notifications for follows, mentions, reblogs, favourites, polls, and quotes

### Password & Email Management
- **OTP-Based Password Reset**: Secure 4-digit OTP verification for password reset
- **Password Change**: Authenticated password change with current password verification
- **Email Change**: OTP-verified email change with session revocation
- **Custom Mailers**: Branded OTP confirmation emails

### Authentication
- **Custom OAuth Behavior**: Platform-specific authentication handling
- **Bristol Cable Integration**: External membership service authentication
- **Channel-Based Login**: Role-based login restrictions for channel platforms
- **Doorkeeper Extensions**: Password grant flow with LDAP/PAM support

### User Preferences
- **Email Notification Settings**: Toggle all email notifications on/off
- **Alt-Text Settings**: User preference for alt-text reminders on media uploads
- **Locale Management**: API endpoint for setting user language preference

### Internationalization (i18n)
- **11 Supported Languages**: English, German, Spanish, French, Italian, Japanese, Portuguese, Brazilian Portuguese, Russian, and Welsh
- **Standardized API Responses**: Consistent, translatable error and success messages
- **Locale-Aware Responses**: API responses respect user's locale preference

### Mailer Customization
- **Branded Templates**: Customizable email templates with logo and brand colors
- **Dynamic Branding**: Support for custom mail header/footer logos via `SiteUpload`
- **App Store Links**: Configurable iOS and Android app store links in emails

### Database Extensions
- Server settings management
- Notification tokens storage
- Drafted statuses support
- User alt-text preferences

## API Endpoints

### Notification Tokens
```
POST   /api/v1/notification_tokens              # Create token
POST   /api/v1/notification_tokens/revoke_token # Revoke token
POST   /api/v1/notification_tokens/update_mute  # Update mute status
GET    /api/v1/notification_tokens/get_mute_status
DELETE /api/v1/notification_tokens/reset_device_tokens/:platform_type
```

### Password Management
```
POST /api/v1/custom_passwords           # Request password reset
PUT  /api/v1/custom_passwords/:id       # Update password
GET  /api/v1/custom_passwords/request_otp
POST /api/v1/custom_passwords/verify_otp
POST /api/v1/custom_passwords/change_password
POST /api/v1/custom_passwords/change_email
```

### User Settings
```
GET  /api/v1/patchwork/email_settings
POST /api/v1/patchwork/email_settings/notification
GET  /api/v1/patchwork/alttext_settings
POST /api/v1/patchwork/alttext_settings/alttext
POST /api/v1/user_locales
```

## Configuration

### Environment Variables
- `AUTO_FOLLOW_ENABLED` - Enable auto-follow on signup
- `AUTO_FOLLOW_ACCOUNTS` - Comma-separated list of accounts to auto-follow
- `FIREBASE_PROJECT_ID` - Firebase project ID for push notifications
- `FIREBASE_KEY_FILE_NAME` - Firebase service account key filename
- `NOTIFICATION_SENDER_NAME` - App name for push notifications
- `MAIL_SENDER_NAME` - Sender name for emails
- `MAIL_LOGO_URL` - Default logo URL for emails
- `LOCAL_DOMAIN` - Instance domain for platform detection
- `MAIN_CHANNEL` - Enable channel-based authentication
- `DEFAULT_EMAIL_NOTIFICATIONS_ENABLED` - Default email notification state

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/patchwork-hub/accounts. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/patchwork-hub/accounts/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [AGPL-3.0 License](https://opensource.org/licenses/AGPL-3.0).

## Code of Conduct

Everyone interacting in the Accounts project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/patchwork-hub/accounts/blob/main/CODE_OF_CONDUCT.md).
