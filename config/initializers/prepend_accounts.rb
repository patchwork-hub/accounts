# frozen_string_literal: true

Rails.application.config.to_prepare do
  Api::V1::AccountsController.prepend(Accounts::Concerns::AccountsCreation)
  Auth::TokensController.prepend(Accounts::Concerns::CustomAuthenticationBehavior) if Object.const_defined?('Auth::TokensController')
  Oauth::TokensController.prepend(Accounts::Concerns::CustomAuthenticationBehavior) if Object.const_defined?('Oauth::TokensController')
  Account.include(Accounts::Concerns::AccountConcern)
  # User.include(OverrideDeviseConfirmation)
  # User.include(OverrideDevisePassword)
  User.include(OverrideChangedPassword)
  REST::CredentialAccountSerializer.prepend(Overrides::CredentialAccountSerializer)
  NotifyService.prepend(Overrides::NotifyServiceExtension)
  AppSignUpService.prepend(Overrides::AppSignUpServiceExtension)
  User.prepend(OverridePrepareNewUser)
  User.include(UserConcern)

  # Temporary timeline fix for Qlub
  Feed.prepend(Accounts::Concerns::FeedConcern)
  Status.include(Accounts::Concerns::StatusConcern)
  Api::V1::Timelines::HomeController.prepend(Accounts::Overrides::HomeExtendedTimeline)
  Api::V1::Timelines::PublicController.prepend(Accounts::Overrides::PublicExtendedTimeline)
  # if ["patchwork.io", "mo-me.social", "newsmast.social", "qlub.channel.org"].include?(ENV['LOCAL_DOMAIN'])
  #   [Admin::DashboardController, Admin::ReportsController].each do |controller|
  #     controller.class_eval do
  #       before_action :authenticate_user!
  #     end
  #   end
  # end
end
