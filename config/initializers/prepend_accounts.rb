# frozen_string_literal: true

Rails.application.config.to_prepare do
  Api::V1::AccountsController.prepend(Accounts::Concerns::AccountsCreation)
  Oauth::TokensController.prepend(Accounts::Concerns::CustomOauthBehavior)
  Account.include(Accounts::Concerns::AccountConcern)
  # User.include(OverrideDeviseConfirmation)
  # User.include(OverrideDevisePassword)
  User.include(OverrideChangedPassword)
  REST::CredentialAccountSerializer.prepend(Overrides::CredentialAccountSerializer)
  NotifyService.prepend(Overrides::NotifyServiceExtension)
  AppSignUpService.prepend(Overrides::AppSignUpServiceExtension)
  User.prepend(OverridePrepareNewUser)
  User.include(UserConcern)

  if ["patchwork.io", "mo-me.social", "newsmast.social", "qlub.channel.org"].include?(ENV['LOCAL_DOMAIN'])
    [Admin::DashboardController, Admin::ReportsController].each do |controller|
      controller.class_eval do
        before_action :authenticate_user!
      end
    end
  end
end
