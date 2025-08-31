module UserConcern
  extend ActiveSupport::Concern

  included do
    after_create :create_user_settings
  end

  private

  def create_user_settings
    Rails.logger.info "++++++++++[AccountsGem] User #{email} was created!+++++++++++++"
    notification_emails = settings.as_json.select do |key, _|
      key.to_s.start_with?("notification_emails.")
    end

    return if notification_emails.present?

    settings = email_notification_attributes(enabled: false)
    update!(settings: settings)
  end

  def email_notification_attributes(enabled: false)
    {
      "always_send_emails" => enabled,
      "notification_emails.follow" => enabled,
      "notification_emails.reblog" => enabled,
      "notification_emails.favourite" => enabled,
      "notification_emails.mention" => enabled,
      "notification_emails.follow_request" => enabled,
      "notification_emails.report" => enabled,
      "notification_emails.pending_account" => enabled,
      "notification_emails.trends" => enabled,
      "notification_emails.appeal" => enabled,
      "notification_emails.software_updates" => enabled ? "critical" : "none"
    }
  end
end
