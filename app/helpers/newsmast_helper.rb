# frozen_string_literal: true

module NewsmastHelper
  extend ActiveSupport::Concern

  def is_newsmast?
    return true if Rails.env.development?

    return true if Rails.env.production? && %w[mastodon.newsmast.org newsmast.social mo-me.social].include?(ENV['LOCAL_DOMAIN'])
    
    false
  end

  def is_mo_me?
    return true if Rails.env.development?

    return true if Rails.env.production? && %w[mo-me.social].include?(ENV['LOCAL_DOMAIN'])
    
    false
  end
end