module OverridePrepareNewUser
  def prepare_new_user!
    AutoFollowDefaultAccountsService.new.call(account)
    BootstrapTimelineWorker.perform_async(account_id)
    ActivityTracker.increment('activity:accounts:local')
    ActivityTracker.record('activity:logins', id)
    UserMailer.welcome(self).deliver_later(wait: 1.hour)
    TriggerWebhookWorker.perform_async('account.approved', 'Account', account_id)
  end
end
