# frozen_string_literal: true

module Accounts::Concerns::AccountConcern
  extend ActiveSupport::Concern

  included do
    has_many :notification_tokens, class_name: 'NotificationToken', dependent: :delete_all, inverse_of: :account

    # Tag follows (via TagFollow model) — followed tags convenience association
    has_many :followed_tags, through: :tag_follows, source: :tag
  end
end
