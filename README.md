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

- **50+ Supported Languages**: English, German, Spanish, French, Italian, Japanese, Portuguese, Brazilian Portuguese, Russian, Welsh, etc...
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

### Deep Linking (iOS & Android)

- **iOS Universal Links**: Serves `apple-app-site-association` at `/.well-known/apple-app-site-association` with correct `application/json` Content-Type
- **Android App Links**: Serves `assetlinks.json` at `/.well-known/assetlinks.json`
- **Environment Variable Configuration**: All app identifiers configured via env vars — no hardcoded values
- **No Nginx Changes Required**: Unlike static file approach, the controller handles Content-Type headers automatically
- **Safe Fallback**: Returns 404 if env vars are not configured

## API Endpoints

### Notification Tokens

```text
POST   /api/v1/notification_tokens              # Create token
POST   /api/v1/notification_tokens/revoke_token # Revoke token
POST   /api/v1/notification_tokens/update_mute  # Update mute status
GET    /api/v1/notification_tokens/get_mute_status
DELETE /api/v1/notification_tokens/reset_device_tokens/:platform_type
```

### Password Management

```text
POST /api/v1/custom_passwords           # Request password reset
PUT  /api/v1/custom_passwords/:id       # Update password
GET  /api/v1/custom_passwords/request_otp
POST /api/v1/custom_passwords/verify_otp
POST /api/v1/custom_passwords/change_password
POST /api/v1/custom_passwords/change_email
```

### User Settings

```text
GET  /api/v1/patchwork/email_settings
POST /api/v1/patchwork/email_settings/notification
GET  /api/v1/patchwork/alttext_settings
POST /api/v1/patchwork/alttext_settings/alttext
POST /api/v1/user_locales
```

### Deep Linking (Well-Known)

```text
GET /.well-known/apple-app-site-association  # iOS Universal Links (AASA)
GET /.well-known/assetlinks.json             # Android App Links
```

## Configuration

### Environment Variables

#### Account Management

- `AUTO_FOLLOW_ENABLED` - Enable auto-follow on signup (`true` or `false`, defaults to disabled)
- `AUTO_FOLLOW_ACCOUNTS` - Comma-separated list of account handles to auto-follow after signup
- `WELCOME_EMAIL_DISABLED` - Disable welcome email sent to new users after signup (set to `true` to disable, defaults to enabled)
- `ALLOWED_SIGNUP_EMAIL_DOMAIN` - Restrict new user registration to specific email domain(s). Comma-separated for multiple domains (e.g., `example.org` or `example01.org,example02.org`). When set, only users with matching email domains can sign up via both web and API. When not set, all email domains are allowed

#### Push Notifications

- `FIREBASE_PROJECT_ID` - Firebase project ID for FCM push notifications (required for push notifications to work)
- `FIREBASE_KEY_FILE_NAME` - Path to Firebase service account JSON key file (required for push notifications to work)
- `NOTIFICATION_SENDER_NAME` - App name displayed in push notification titles (defaults to `Development Patchwork`)
- `SKIP_SIGNUP_PUSH_NOTI` - Skip sending push notifications for new user sign-ups (`admin.sign_up` notification type). Must be present and set to `true` to disable (defaults to enable)

#### Email Configuration

- `MAIL_SENDER_NAME` - Name used as sender for all outgoing emails (defaults to `Development Patchwork`)
- `MAIL_LOGO_URL` - Default URL for logo image in email templates (defaults to Patchwork demo logo)
- `IOS_APP_STORE_URL` - URL to iOS app in App Store; when set, displays app store link in email footer
- `ANDROID_APP_STORE_URL` - URL to Android app in Google Play; when set, displays app store link in email footer
- `PRIVACY_POLICY_URL` - URL to privacy policy; when set along with `TERMS_AND_CONDITIONS_URL`, displays policy links in email footer
- `TERMS_AND_CONDITIONS_URL` - URL to terms of service; when set along with `PRIVACY_POLICY_URL`, displays policy links in email footer
- `DEFAULT_VERIFICATION_ENABLED` - Use default verification or customized verification for whether new user registration is verified (`true` = default, `false` = customized)

#### User Preferences

- `DEFAULT_EMAIL_NOTIFICATIONS_ENABLED` - Default email notification state for new users (`true` or `false`)

#### Ghost Integration (Optional)

- `GHOST_URL` - Base URL of Ghost CMS instance (required only if using Ghost subscriptions feature, e.g., `https://newsletter.example.com`)
- `GHOST_ADMIN_API_KEY` - Ghost Admin API key in format `id:secret` for authentication (required only if using Ghost subscriptions feature)

#### Deep Linking

- `IOS_APP_ID` - Full iOS app identifier in `TeamID.BundleID` format (e.g., `VA45Q6RWV3.com.csidnetwork.social`). Required for `/.well-known/apple-app-site-association` to be served; returns 404 if not set
- `IOS_DEEPLINK_PATHS` - Comma-separated URL path patterns for iOS deep links (optional, defaults to `/@*,/@*/*`)
- `ANDROID_PACKAGE_NAME` - Android app package name (e.g., `com.csidnetwork.social`). Required for `/.well-known/assetlinks.json` to be served; returns 404 if not set
- `ANDROID_SHA256_CERT_FINGERPRINTS` - Comma-separated SHA-256 certificate fingerprints for Android app verification (e.g., `3C:0D:6D:2F:70:2C:0D:ED:25:FA:3A:83:DF:B3:8C:C9:67:F7:26:38:4E:6B:67:1E:CF:88:53:61:7D:C7:8D:22`). Required for `/.well-known/assetlinks.json` to be served; returns 404 if not set

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/patchwork-hub/accounts>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/patchwork-hub/accounts/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [AGPL-3.0 License](https://opensource.org/licenses/AGPL-3.0).

## Code of Conduct

Everyone interacting in the Accounts project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/patchwork-hub/accounts/blob/main/CODE_OF_CONDUCT.md).
