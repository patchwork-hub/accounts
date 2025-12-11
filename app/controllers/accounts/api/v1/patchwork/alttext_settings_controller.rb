# frozen_string_literal: true

module Accounts::Api::V1::Patchwork
  class AlttextSettingsController < Api::BaseController
    include Accounts::Concerns::ApiResponseHelper

    before_action -> { doorkeeper_authorize! :read, :write }
    before_action :require_user!

    def index
      render_success(current_user.alttext_enabled, "api.messages.success", :ok)
    end

    def change_alttext_setting
      # atttext_settings = enable_alttext_setting ? email_notification_attributes(enabled: true) : email_notification_attributes(enabled: false)
      if current_user.update(alttext_enabled: enable_alttext_setting)
        render_success(current_user.alttext_enabled, "api.messages.success", :ok)
      else
        render_error("api.errors.unprocessable_entity", :unprocessable_entity)
      end
    end

    private

    def enable_alttext_setting
      truthy_param?(alttext_setting_params[:enabled])
    end

    def alttext_setting_params
      params.permit(:enabled)
    end

    def truthy_param?(key)
      ActiveModel::Type::Boolean.new.cast(key)
    end
  end
end
