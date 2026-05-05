# frozen_string_literal: true

module Accounts::Concerns::AccountConcern
  extend ActiveSupport::Concern

  included do
    has_many :notification_tokens, class_name: 'Accounts::NotificationToken', dependent: :delete_all, inverse_of: :account
    has_many :patchwork_settings, class_name: 'Accounts::PatchworkSetting', foreign_key: :account_id, dependent: :destroy
  end
end
