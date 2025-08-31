# frozen_string_literal: true

class CustomPasswordsMailer < ApplicationMailer
  layout 'email'

  def reset_password_confirmation
    @user = params[:user]
    sender_name = case ENV['LOCAL_DOMAIN']
              when 'channel.org'
                'Channel'
              when 'mo-me.social'
                'mo-me.social'
              else
                'Newsmast'
              end
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
