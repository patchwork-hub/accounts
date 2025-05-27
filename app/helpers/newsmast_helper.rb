# frozen_string_literal: true

module NewsmastHelper
  extend ActiveSupport::Concern

  def is_newsmast?
    return true if Rails.env.development?
    Rails.env.production? && ENV['LOCAL_DOMAIN'] == 'newsmast.social'
  end
end