# frozen_string_literal: true

module NonChannelHelper
  extend ActiveSupport::Concern

  def is_non_channel?
    return true if Rails.env.development?

    return true if Rails.env.production? && %w[mastodon.newsmast.org newsmast.social mo-me.social patchwork.io qlub.social qlub.channel.org thebristolcable.social twt.channel.org].include?(ENV['LOCAL_DOMAIN'])
    
    false
  end
end