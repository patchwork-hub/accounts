# frozen_string_literal: true

class CustomNotificationService < BaseService
  include NonChannelHelper

  def call(recipient, notification)
    notification_tokens = NotificationToken.where(account_id: recipient.id)
    return nil if notification_tokens.empty? || notification_tokens.any? { |token| token.mute }

    body = ''
    destination_id = 0
    reblogged_id = 0
    visibility = ''
    from_account_username = Account.find(notification.from_account_id).username

    case notification.type
    when :status
      body = I18n.t('notification_mailer.status.subject', name: from_account_username)
      destination_id = Status.find(notification.activity_id).id
    when :update
      body = I18n.t('notification_mailer.update.subject', name: from_account_username)
      destination_id = Status.find(notification.activity_id).id
    when :reblog
      body = I18n.t('notification_mailer.reblog.subject', name: from_account_username)
      status = Status.find(notification.activity_id)
      destination_id = status.id
      reblogged_id = status.reblog_of_id
    when :favourite
      body = I18n.t('notification_mailer.favourite.subject', name: from_account_username)
      favourite = Favourite.find(notification.activity_id)
      destination_id = Status.find(favourite.status_id).id
    when :mention
      mention = Mention.find(notification.activity_id)
      status = Status.find(mention.status_id)
      body = status.visibility === Status.visibilities[:direct] ? I18n.t('notification.mention.direct_message', name: from_account_username) : I18n.t('notification_mailer.mention.subject', name: from_account_username)
      destination_id = status.id
      visibility = status.visibility
    when :poll
      poll = Poll.find(notification.activity_id)
      body = notification.from_account_id == poll.account_id ? I18n.t('notification.poll.ended_you') : I18n.t('notification.poll.ended_voted')
      destination_id = Status.find(poll.status_id).id
    when :follow
      body = I18n.t('notification_mailer.follow.subject', name: from_account_username)
      destination_id = notification.from_account_id
    when :follow_request
      body = I18n.t('notification_mailer.follow_request.subject', name: from_account_username)
      destination_id = notification.from_account_id
    when :quote
      body = I18n.t('notification_mailer.quote.subject', name: from_account_username)
      destination_id = Quote.find(notification.activity_id)&.status_id
    when :quoted_update
      body = I18n.t('notification_mailer.update.subject', name: from_account_username)
      destination_id = Quote.find(notification.activity_id)&.status_id
    end

    data = {
      noti_type: notification.type,
      destination_id: destination_id.to_s,
      reblogged_id: reblogged_id.to_s,
      visibility: visibility,
    }
    # ios & android
    ios_android_devices = notification_tokens.where.not(platform_type: 'huawei').pluck(:notification_token)

    app_title = ENV['NOTIFICATION_SENDER_NAME'] || 'Development Patchwork'

    ios_android_devices.each do |device|
      FirebaseNotificationService.send_notification(device, app_title, body, data)
    end

    # ## huawei
    # huawei_devices = notification_tokens.where(platform_type: 'huawei').pluck(:notification_token)
    # return unless huawei_devices.any? ## ios & android

    # huawei = HuaweiCloudMessaging.new
    # huawei.send_message(title, destination, destination_id, huawei_devices)
  end
end
