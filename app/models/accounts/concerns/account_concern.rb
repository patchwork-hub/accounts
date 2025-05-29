# frozen_string_literal: true

module Accounts::Concerns::AccountConcern
  extend ActiveSupport::Concern

  included do
    has_many :notification_tokens, class_name: 'NotificationToken', dependent: :delete_all, inverse_of: :account
  end
end
