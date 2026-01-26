# frozen_string_literal: true

class UpdateChannelNameServices < BaseService
  include NonChannelHelper

  def call(account, options = {})
    return if is_non_channel?

    return unless options[:type] == 'channel_feed'

    return unless Object.const_defined?('Accounts::CommunityAdmin')
    
    return unless defined?(Accounts::CommunityAdmin) && Accounts::CommunityAdmin.respond_to?(:find_by)

    community_admin = Accounts::CommunityAdmin.find_by(
      account_id: account.id,
      is_boost_bot: true,
      account_status: Accounts::CommunityAdmin.account_statuses['active']
    )
    return unless community_admin

    community = community_admin.community

    community.update!(
      name: account.display_name.strip.presence,
      description: account.note,
      avatar_image: account.avatar,
      banner_image: account.header
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "[UpdateChannelNameServices] Community update failed: #{e.record.class} - #{e.message}"
  end
end
