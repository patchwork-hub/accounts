# frozen_string_literal: true

module Accounts::Concerns::UserSettingExtend
  extend ActiveSupport::Concern
  include NonChannelHelper

  def setting_default_privacy

    return false unless defined?(Accounts::Community) && Accounts::Community.respond_to?(:find_by)

    # Default visibility setting
    community_privacy = Accounts::Community.default_privacy(self)
    return community_privacy if community_privacy.present?

    settings['default_privacy'] || (account.locked? ? 'private' : 'public')
  end
end