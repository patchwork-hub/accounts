module Accounts::Api::V1::Patchwork
  class AccountDeletionController < Api::BaseController
    include Accounts::Concerns::ApiResponseHelper
    before_action -> { doorkeeper_authorize! :read, :write }
    before_action :require_user!
    before_action :set_account, only: [:destroy]

    def destroy
      account = @account
      if account.nil?
        render_error("api.errors.not_found", :not_found)
        return
      end

      AccountDeletionWorker.perform_async(account.id,
      {
        'reserve_username' => false,
        'reserve_email' => false,
      })
      render_success({}, 'api.messages.deleted', :accepted)
    end

    private

    def set_account
      @account = Account.find_by(id: params[:id])
    end

  end
end
