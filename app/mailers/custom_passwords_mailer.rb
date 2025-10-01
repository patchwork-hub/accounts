# frozen_string_literal: true

class CustomPasswordsMailer < ApplicationMailer
  layout 'email'

  helper BrandColorHelper
  helper LogoHelper

  def reset_password_confirmation
    @user = params[:user]

    sender_name = case ENV['LOCAL_DOMAIN']
    when 'channel.org'
      'Channels'
    when 'mo-me.social'
      'Mo Me'
    when 'patchwork.io'
      'Patchwork'
    when 'newsmast.social', 'backend.newsmast.org'
      'Newsmast'
    when 'staging.patchwork.online'
      'Channels staging'
    when 'qlub.channel.org', 'qlub.social'
      'Qlub'
    when 'thebristolcable.social'
      'Bristol Cable'
    else
      'Development'
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
