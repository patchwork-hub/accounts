# frozen_string_literal: true

module Accounts::Api::V1::Patchwork
  class EmailSettingsController < Api::BaseController
    before_action -> { doorkeeper_authorize! :read, :write }
    before_action :require_user!

    def index
      notification_emails = current_user.settings.as_json.select do |key, _|
        key.to_s.start_with?("notification_emails.")
      end
      notification_emails.delete(:'notification_emails.software_updates')
      all_same = notification_emails.values.uniq.size == 1
      result_variable = all_same ? notification_emails.values.first : true
      render json: { data: notification_emails.empty? ? false : result_variable }, status: 200
    end

    def email_notification
      settings = enable_email_notification? ? email_notification_attributes(enabled: true) : email_notification_attributes(enabled: false)
      if current_user.update(settings: settings)
        render json: { message: "Changes successfully saved." }, status: 200
      else
        render json: { error: "Something went wrong!" }, status: 422
      end
    end

    private

    def enable_email_notification?
      truthy_param?(email_notification_params[:allowed])
    end

    def email_notification_params
      params.permit(:allowed)
    end

    def truthy_param?(key)
      ActiveModel::Type::Boolean.new.cast(key)
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
end
