# frozen_string_literal: true

require 'accounts/application_record'

module Accounts
  class Community < ApplicationRecord
    self.table_name = 'patchwork_communities'

    IMAGE_MIME_TYPES = ['image/svg+xml', 'image/png', 'image/jpeg', 'image/jpg', 'image/webp'].freeze
    LIMIT = 2.megabytes

    has_attached_file :logo_image
    has_attached_file :avatar_image
    has_attached_file :banner_image

    has_many :community_admins,
    foreign_key: 'patchwork_community_id',
    dependent: :destroy,
    class_name: 'Accounts::CommunityAdmin'

    has_one :community_post_type,
    foreign_key: 'patchwork_community_id',
    dependent: :destroy,
    class_name: 'Accounts::CommunityPostType'

    has_many :community_hashtags,
    class_name: 'Accounts::CommunityHashtag',
    foreign_key: 'patchwork_community_id',
    dependent: :destroy

    has_one :content_type,
    class_name: 'Accounts::ContentType',
    foreign_key: 'patchwork_community_id',
    dependent: :destroy

    validates :name, presence: true, uniqueness: true

    enum :visibility, public_access: 0, guest_access: 1, private_local: 2

    enum :post_visibility, { public_visibility: 0, unlisted: 1, followers_only: 2, direct: 3 }

    validates_attachment :logo_image,
                          content_type: { content_type: IMAGE_MIME_TYPES },
                          size: { less_than: LIMIT }

    validates_attachment :avatar_image,
                          content_type: { content_type: IMAGE_MIME_TYPES },
                          size: { less_than: LIMIT }

    validates_attachment :banner_image,
                          content_type: { content_type: IMAGE_MIME_TYPES },
                          size: { less_than: LIMIT }

  end
end
