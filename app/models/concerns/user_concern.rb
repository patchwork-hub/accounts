module UserConcern
  extend ActiveSupport::Concern
  include EmailNotificationAttributesConcern

  included do
    after_create :create_user_settings, :apply_server_setting_to_account, :set_bluesky_bridge_enable
  end

  private

  def create_user_settings
    notification_emails = settings.as_json.select do |key, _|
      key.to_s.start_with?("notification_emails.")
    end

    return if notification_emails.present?

    enabled_notification = ENV['DEFAULT_EMAIL_NOTIFICATIONS_ENABLED'] == 'true'? true : false     
    
    settings = email_notification_attributes(enabled: enabled_notification)
    update!(settings: settings)
  end

  def apply_server_setting_to_account
    return unless Object.const_defined?('Accounts::ServerSetting')

    setting = Accounts::ServerSetting.find_by(name: "Automatic Search Opt-in")
    return unless setting.present? && account.present?

    opt_out = ActiveModel::Type::Boolean.new.cast(setting.value)
    account.update(
      discoverable: !opt_out,
      indexable: !opt_out
    )
    update!(settings_attributes: { noindex: opt_out })
  end

  def set_bluesky_bridge_enable
    return unless Object.const_defined?('Accounts::ServerSetting')

    return unless Accounts::ServerSetting.find_by(name: "Automatic Bluesky bridging for new users")&.value

    update!(bluesky_bridge_enabled: true)
  end
end
