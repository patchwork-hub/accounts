# frozen_string_literal: true

module Accounts::Concerns::AccountsUpdate
  extend ActiveSupport::Concern

  def update
    @account = current_account
    UpdateAccountService.new.call(@account, account_params, raise_error: true)
    current_user.update(user_params) if user_params
    ActivityPub::UpdateDistributionWorker.perform_in(ActivityPub::UpdateDistributionWorker::DEBOUNCE_DELAY, @account.id)
    # We need to update the channel name in the Dashboard if the account is a channel feed, and the name or avatar has been changed.
    UpdateChannelNameServices.new.call(@account, skip_dashboard_profile: skip_dashboard_profile?)
    render json: @account, serializer: REST::CredentialAccountSerializer
  rescue ActiveRecord::RecordInvalid => e
    render json: ValidationErrorFormatter.new(e).as_json, status: 422
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
