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

      resources :notification_tokens, only: [:create] do
        collection do
          post :revoke_token, to: 'notification_tokens#revoke_notification_token'
          post :update_mute, to: 'notification_tokens#update_mute'
          get :get_mute_status, to: 'notification_tokens#get_mute_status'
          delete '/reset_device_tokens/:platform_type', to: 'notification_tokens#reset_device_tokens'
        end
      end

      namespace :patchwork do
        resources :email_settings, only: [:index] do
          collection do
            post '/notification', to: 'email_settings#email_notification'
          end
        end
      end

    end
  end
end

