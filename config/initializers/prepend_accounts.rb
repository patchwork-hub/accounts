# frozen_string_literal: true

Rails.application.config.to_prepare do
  # Controller extensions
  Api::V1::AccountsController.prepend(Accounts::Concerns::AccountsCreation)
  
  # Handle both OAuth controller variants
  %w[Oauth::TokensController OAuth::TokensController].each do |controller_class|
    next unless Object.const_defined?(controller_class)
    controller_class.constantize.prepend(Accounts::Concerns::CustomTokensCreation)
  end

  # Model extensions
  Account.include(Accounts::Concerns::AccountConcern)
  
  # User authentication overrides  
  User.include(OverrideDeviseConfirmation)
  User.include(OverrideDevisePassword)

  # Serializer extensions
  REST::CredentialAccountSerializer.prepend(Overrides::CredentialAccountSerializer)
  
  # Service extensions
  NotifyService.prepend(Overrides::NotifyServiceExtension)
end
