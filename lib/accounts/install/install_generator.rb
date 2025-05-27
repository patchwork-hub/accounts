# frozen_string_literal: true

module Accounts
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    
    def copy_initializer_file
      copy_file "account_initializer.rb", Rails.root + "config/initializers/prepend_accounts.rb"
    end
    
    def rake_db
      rake("accounts:install:migrations")
      rake("db:migrate")
    end
    
  end
end