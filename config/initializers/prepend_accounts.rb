# frozen_string_literal: true

Rails.application.config.to_prepare do
  Api::V1::AccountsController.prepend(Accounts::Concerns::AccountsCreation)
  Auth::TokensController.prepend(Accounts::Concerns::CustomAuthenticationBehavior) if Object.const_defined?('Auth::TokensController')
  OAuth::TokensController.prepend(Accounts::Concerns::CustomAuthenticationBehavior) if Object.const_defined?('OAuth::TokensController')
  Account.include(Accounts::Concerns::AccountConcern)
  User.include(OverrideChangedPassword)
  REST::CredentialAccountSerializer.prepend(Overrides::CredentialAccountSerializer)
  NotifyService.prepend(Overrides::NotifyServiceExtension)
  AppSignUpService.prepend(Overrides::AppSignUpServiceExtension)
  User.prepend(OverridePrepareNewUser)
  User.include(UserConcern)
  Auth::SessionsController.prepend(Accounts::Concerns::CustomSessionBehavior) if Object.const_defined?('Auth::SessionsController')
  Api::V1::Accounts::CredentialsController.prepend(Accounts::Concerns::AccountsUpdate)
  User::HasSettings.prepend(Accounts::Concerns::UserSettingExtend)
  Api::V2::SearchController.prepend(Accounts::Concerns::SearchControllerExtension)
  SearchService.prepend(Overrides::SearchServiceExtension)
  AccountSearchService.prepend(Overrides::AccountSearchServiceExtension)

  # Ensure authentication for Admin Moderation and Administration routes
  [Admin::DashboardController, Admin::ReportsController].each do |controller|
    controller.class_eval do
      before_action :authenticate_user!
    end
  end
end
