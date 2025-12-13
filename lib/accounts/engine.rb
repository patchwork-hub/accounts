# frozen_string_literal: true

module Accounts
  class Engine < ::Rails::Engine
    isolate_namespace Accounts

    config.after_initialize do
      Doorkeeper.configuration.instance_eval do
        # Add 'password' to existing grant_flows without replacing others
        @grant_flows = (@grant_flows || []) | ['password']
        
        @resource_owner_from_credentials = proc do |_routes|
            user   = User.authenticate_with_ldap(email: request.params[:username], password: request.params[:password]) if Devise.ldap_authentication
            user ||= User.authenticate_with_pam(email: request.params[:username], password: request.params[:password]) if Devise.pam_authentication

            if user.nil?
              user = User.find_by(email: request.params[:username])
              user = nil unless user&.valid_password?(request.params[:password])
            end

            user unless user&.otp_required_for_login?
          end
        end
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match?(root.to_s)
        migrations_path = root.join("db/migrate").to_s
        app.config.paths["db/migrate"] << migrations_path
      end
    end

    initializer 'accounts.load_routes' do |app|
      app.routes.prepend do
        mount Accounts::Engine => "/", :as => :accounts
      end
    end

    config.autoload_paths << File.expand_path("../app/services", __FILE__)
    config.autoload_paths << File.expand_path("../app/workers", __FILE__)

  end
end
