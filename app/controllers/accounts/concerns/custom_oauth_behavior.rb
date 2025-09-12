# frozen_string_literal: true

module Accounts::Concerns::CustomOauthBehavior
  extend ActiveSupport::Concern
  include NonChannelHelper

  def create

    if client_credentials? || authorization_code?
      super
      return 
    end

    error_message = if is_non_channel?
      LoginService.new(oauth_params).newsmast_login || nil
    else
      LoginService.new(oauth_params).channel_login || nil
    end

    error_message.nil? ? super : render_error(error_message)
  end

  private

  def render_error(error)
    render json: { error: error }, status: 401
  end

  def client_credentials?
    oauth_params[:grant_type] == 'client_credentials'
  end

  def authorization_code?
    oauth_params[:grant_type] == 'authorization_code'
  end

  def oauth_params
    params.permit(
      :username,
      :is_web_login,
      :grant_type,
      :code
    )
  end

end
