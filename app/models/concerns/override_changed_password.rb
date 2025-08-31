# frozen_string_literal: true

module OverrideChangedPassword
  extend ActiveSupport::Concern

  included do
    # Add a transient attribute to control notification skipping
    attr_accessor :skip_password_change_notification

    # Override or modify render_and_send_devise_message
    def render_and_send_devise_message(notification_type, *args)
      # Skip sending the password_change email if the flag is set
      return if notification_type == skip_password_change_notification

      # Otherwise, proceed with sending the email
      devise_mailer.send(notification_type, self, *args).deliver_later
    end

    # Optionally override Devise's default notification method
    def send_password_change_notification
      # Do nothing if skip_password_change_notification is true
      return if skip_password_change_notification

      # Otherwise, call the default Devise notification
      render_and_send_devise_message(:password_change)
    end
  end
end 