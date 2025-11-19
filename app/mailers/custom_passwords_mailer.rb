# frozen_string_literal: true

class CustomPasswordsMailer < ApplicationMailer
  layout 'email'

  helper BrandColorHelper
  helper LogoHelper

  def reset_password_confirmation
    @user = params[:user]

    sender_name = ENV.fetch('MAIL_SENDER_NAME', 'Development Patchwork')

    if @user.present?
      @subject = 'OTP verification code'
      mail(
        to: @user.email,
        subject: @subject,
        from: "#{sender_name} <#{ENV['SMTP_FROM_ADDRESS']}>"
      )
    end
  end
end
