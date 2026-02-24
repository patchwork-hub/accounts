# frozen_string_literal: true

Accounts::Engine.routes.draw do
  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :custom_passwords, only: %i[create update] do
        collection do
          post :verify_otp, to: "custom_passwords#verify_otp"
          get :request_otp, to: "custom_passwords#request_otp"
          post :change_password, to: "custom_passwords#change_password"
          post :change_email, to: "custom_passwords#change_email"
          post :bristol_cable_sign_in, to: "custom_passwords#bristol_cable_sign_in"
        end
      end

      resources :notification_tokens, only: [:create] do
        collection do
          post :revoke_token, to: "notification_tokens#revoke_notification_token"
          post :update_mute, to: "notification_tokens#update_mute"
          get :get_mute_status, to: "notification_tokens#get_mute_status"
          delete "/reset_device_tokens/:platform_type", to: "notification_tokens#reset_device_tokens"
        end
      end

      resources :user_locales, only: [:create]

      resources :channels, only: [] do
        collection do
          get :starter_packs_channels
        end
        member do
          get :starter_packs_detail
        end
      end

      namespace :patchwork do
        resources :alttext_settings, only: [:index] do
          collection do
            post "/alttext", to: "alttext_settings#change_alttext_setting"
          end
        end
        resources :email_settings, only: [:index] do
          collection do
            post "/notification", to: "email_settings#email_notification"
          end
        end
      end

      post "/delete_account", to: "accounts#delete_account"

      namespace :accounts do
        get "leicester_notification", to: "patchwork_settings#leicester_news_notification"
        post "leicester_notification", to: "patchwork_settings#update_leicester_news_notification"
        post "subscribe_leicester", to: "ghost_subscriptions#manage_subscription"
      end
    end
  end
end
