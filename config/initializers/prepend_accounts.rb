# frozen_string_literal: true

Rails.application.config.to_prepare do
  Api::V1::AccountsController.prepend(Accounts::Concerns::AccountsCreation)
  Oauth::TokensController.prepend(Accounts::Concerns::CustomOauthBehavior)
  Account.include(Accounts::Concerns::AccountConcern)
  User.include(OverrideDeviseConfirmation)
  User.include(OverrideDevisePassword)
  REST::CredentialAccountSerializer.prepend(Overrides::CredentialAccountSerializer)
  NotifyService.prepend(Overrides::NotifyServiceExtension)
end
