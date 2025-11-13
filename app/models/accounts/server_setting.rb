# frozen_string_literal: true

require 'accounts/application_record'

module Accounts
  class ServerSetting < ApplicationRecord
    self.table_name = 'server_settings'

    validates :optional_value, presence: true, allow_nil: true

    belongs_to :parent, class_name: "Accounts::ServerSetting", optional: true
    has_many :children, class_name: "Accounts::ServerSetting", foreign_key: "parent_id"
  end
end
