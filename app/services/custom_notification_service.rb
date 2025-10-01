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
      body = "#{from_account_username} just posted"
      destination_id = Status.find(notification.activity_id).id
    when :update
      body = "#{from_account_username} edited a post"
      destination_id = Status.find(notification.activity_id).id
    when :reblog
      body = "#{from_account_username} boosted your status"
      status = Status.find(notification.activity_id)
      destination_id = status.id
      reblogged_id = status.reblog_of_id
    when :favourite
      body = "#{from_account_username} favourited your status"
      favourite = Favourite.find(notification.activity_id)
      destination_id = Status.find(favourite.status_id).id
    when :mention
      mention = Mention.find(notification.activity_id)
      status = Status.find(mention.status_id)
      message = status.visibility === Status.visibilities[:direct] ? "#{from_account_username} send you a message" : "#{from_account_username} mentioned you"
      body = message
      destination_id = status.id
      visibility = status.visibility
    when :poll
      poll = Poll.find(notification.activity_id)
      body = notification.from_account_id == poll.account_id ? 'Your poll has ended' : 'A poll you voted in has ended'
      destination_id = Status.find(poll.status_id).id
    when :follow
      body = "#{from_account_username} followed you"
      destination_id = notification.from_account_id
    when :follow_request
      body = "#{from_account_username} has requested to follow you"
      destination_id = notification.from_account_id
    end

    data = {
      noti_type: notification.type,
      destination_id: destination_id.to_s,
      reblogged_id: reblogged_id.to_s,
      visibility: visibility,
    }
    # ios & android
    ios_android_devices = notification_tokens.where.not(platform_type: 'huawei').pluck(:notification_token)

    app_title = case ENV['LOCAL_DOMAIN']
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
    when 'qlub.channel.org'
      'Qlub'
    when 'thebristolcable.social'
      'Bristol Cable'
    else
      'Development'
    end

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
