# frozen_string_literal: true

module Accounts::Overrides::PublicExtendedTimeline
  PERMITTED_PARAMS = %i(local remote limit only_media with_replies).freeze

  def public_feed
    PublicFeed.new(
      current_account,
      local: truthy_param?(:local),
      remote: truthy_param?(:remote),
      only_media: truthy_param?(:only_media),
      with_replies: truthy_param?(:with_replies)
    )
  end
end