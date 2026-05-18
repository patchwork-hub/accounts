# frozen_string_literal: true

require 'accounts/application_record'

module Accounts
  class PatchworkSetting < ApplicationRecord
    self.table_name = 'patchwork_settings'

    belongs_to :account, class_name: '::Account'

    enum :app_name, { patchwork: 0, newsmast: 1, leicester: 2, findout: 3 }, default: :patchwork

    validates :account, presence: true, uniqueness: { scope: :app_name, case_sensitive: false }
    validates :app_name, presence: true
    validates :settings, presence: true
  end
end
