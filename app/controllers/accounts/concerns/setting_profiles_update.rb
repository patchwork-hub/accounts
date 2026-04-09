# frozen_string_literal: true

module Accounts::Concerns::SettingProfilesUpdate
  extend ActiveSupport::Concern

  def update
    if UpdateAccountService.new.call(@account, account_params)
      ActivityPub::UpdateDistributionWorker.perform_in(ActivityPub::UpdateDistributionWorker::DEBOUNCE_DELAY, @account.id)
      # We need to update the channel name in the Dashboard if the account is a channel feed, and the name or avatar has been changed.
      UpdateChannelNameServices.new.call(@account, skip_dashboard_profile: skip_dashboard_profile?)
      redirect_to settings_profile_path, notice: I18n.t('generic.changes_saved_msg')
    else
      @account.build_fields
      render :show
    end
  end

  private

  def skip_dashboard_profile?
    return true if truthy_param?(params[:skip_dashboard_profile])
    
    false
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(key)
  end
end
