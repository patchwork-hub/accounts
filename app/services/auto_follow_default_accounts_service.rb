class AutoFollowDefaultAccountsService < BaseService
  def call(source_account)
    return unless source_account.local?

    set_default_follow_accounts.each do |acct|
      follow_account(source_account, acct)
    end
  end

  private

  def set_default_follow_accounts
    case ENV['LOCAL_DOMAIN']
    when 'patchwork.io'
      ['newsmast@newsmast.social']
    when 'mo-me.social'
      ['mediarevolution@channel.org']
    when 'qlub.channel.org'
      ['@meadmin@qlub.social', '@qlub@qlub.social', '@kath@qlub.social']
    else
      []
    end
  end

  def follow_account(source_account, target_acct)
    target_account = ResolveAccountService.new.call(target_acct)
    return if target_account.nil?

    FollowService.new.call(source_account, target_account, bypass_locked: true, bypass_limit: true)
  rescue StandardError => e
    Rails.logger.error "Failed to auto-follow #{target_acct} for #{source_account.acct}: #{e.message}"
  end
end
