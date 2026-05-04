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
      notification_request = update_noti_request!
      if @notification.type == :mention && notification_request.present?
        mention = Mention.find(@notification.activity_id)
        status = Status.find(mention.status_id)
        CustomNotificationService.new.call(@recipient, @notification, notification_request) if notification_request.last_status_id == status.id
      end
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

  private

  def update_noti_request!
    return unless %i(mention quote).include?(@notification.type)

    notification_request = NotificationRequest.find_or_initialize_by(account_id: @recipient.id, from_account_id: @notification.from_account_id)
    notification_request.last_status_id = @notification.target_status.id
    notification_request.save

    notification_request
  end
end