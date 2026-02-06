# frozen_string_literal: true

require 'accounts/application_record'

module Accounts
  class CommunityHashtag < ApplicationRecord
    self.table_name = 'patchwork_communities_hashtags'

    belongs_to :community,
              class_name: 'Accounts::Community',
              foreign_key: 'patchwork_community_id'
  end
end
