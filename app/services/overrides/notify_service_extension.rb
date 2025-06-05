module Overrides::NotifyServiceExtension
  def call(recipient, type, activity)
    return if recipient.user.nil?

    @recipient    = recipient
    @activity     = activity
    @notification = Notification.new(account: @recipient, type: type, activity: @activity)

    # For certain conditions we don't need to create a notification at all
    return if drop?

    @notification.filtered = filter?
    @notification.set_group_key!
    @notification.save!

    # It's possible the underlying activity has been deleted
    # between the save call and now
    return if @notification.activity.nil?

    if @notification.filtered?
      update_notification_request!
    else
      push_notification!
      push_to_conversation! if direct_message?
      send_email! if email_needed?
      CustomNotificationService.new.call(@recipient, @notification)
    end
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def send_email!
    return unless NotificationMailer.respond_to?(@notification.type)

    NotificationMailer
      .with(recipient: @recipient, notification: @notification)
      .public_send(@notification.type)
      .deliver_later
  end
end