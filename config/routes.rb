# frozen_string_literal: true

Accounts::Engine.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do

      resources :custom_passwords, only: [:create, :update] do
        collection do
          post :verify_otp, to: 'custom_passwords#verify_otp'
          get :request_otp, to: 'custom_passwords#request_otp'
          post :change_password, to: 'custom_passwords#change_password'
          post :change_email, to: 'custom_passwords#change_email'
        end
      end

    end
  end
end

