# frozen_string_literal: true

module OverrideDevisePassword
  extend ActiveSupport::Concern

  included do
    # Override Devise's send_reset_password_instructions method
    def send_reset_password_instructions
      token = set_reset_password_token
      send_reset_password_instructions_notification(token)
      token
    end

    # Override Devise's send_password_change_notification method
    def send_password_change_notification
      # Do nothing - skip sending password change notification
    end

    private

    def send_reset_password_instructions_notification(token)
      # Do nothing - skip sending reset password instructions
    end
  end
end 