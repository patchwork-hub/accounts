# frozen_string_literal: true

module Accounts::Concerns::AccountsCreation
  extend ActiveSupport::Concern
  include NonChannelHelper
  
  def create
    token    = AppSignUpService.new.call(doorkeeper_token.application, request.remote_ip, account_params)
    response = Doorkeeper::OAuth::TokenResponse.new(token)

    headers.merge!(response.headers)

    self.response_body = Oj.dump(response.body)
    self.status        = response.status
    create_community_admin unless is_non_channel?
    generate_opt_token
  rescue ActiveRecord::RecordInvalid => e
    render json: ValidationErrorFormatter.new(e, 'account.username': :username, 'invite_request.text': :reason).as_json, status: 422
  end

    private

    def generate_opt_token
      user = User.find_by(email: account_params[:email])
      return unless user && defined?(CustomPasswordsMailer)

      user.otp_secret = SecureRandom.random_number(10_000).to_s.rjust(4, '0')
      user.save!
      CustomPasswordsMailer.with(user: user).reset_password_confirmation.deliver_later
    end

    def create_community_admin
    return unless Object.const_defined?('Accounts::CommunityAdmin')

    return unless defined?(Accounts::CommunityAdmin) && Accounts::CommunityAdmin.respond_to?(:find_by)

      community_admin = Accounts::CommunityAdmin.new(
        email: account_params[:email],
        username: account_params[:username],
        password: account_params[:password]
      )
      community_admin.save
    end
end