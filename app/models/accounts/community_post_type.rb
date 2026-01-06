# frozen_string_literal: true

require 'accounts/application_record'

module Accounts
  class CommunityPostType < ApplicationRecord
    self.table_name = 'patchwork_community_post_types'

    belongs_to :community,
              class_name: 'Accounts::Community',
              foreign_key: 'patchwork_community_id'
  end
end
