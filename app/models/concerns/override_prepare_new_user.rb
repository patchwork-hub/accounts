module OverridePrepareNewUser
  def prepare_new_user!
    if ENV["AUTO_FOLLOW_ENABLED"].present? && ENV["AUTO_FOLLOW_ENABLED"].to_s.downcase == "true"
      AutoFollowDefaultAccountsService.new.call(account)
    end
    BootstrapTimelineWorker.perform_async(account_id)
    ActivityTracker.increment("activity:accounts:local")
    ActivityTracker.record("activity:logins", id)
    # We do not send out welcome email
    # UserMailer.welcome(self).deliver_later(wait: 1.hour)
    TriggerWebhookWorker.perform_async("account.approved", "Account", account_id)
  end
end
