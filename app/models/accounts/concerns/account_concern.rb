# frozen_string_literal: true

module Accounts::Concerns::AccountConcern
  extend ActiveSupport::Concern

  included do
    #scope :accounts, -> { where.not(domain: nil) }
  end
end
