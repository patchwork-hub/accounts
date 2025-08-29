# API Response Helper for internationalized API responses
# This module provides standardized response methods with I18n support for API controllers

module Accounts::Concerns::ApiCustomResponseHelper
  extend ActiveSupport::Concern

  private

  # result response
  def render_result(data = {}, message_key = 'api.messages.success', status = :ok, additional_params = {})
    # Use the reusable translation method
    translated_message = get_translated_message(message_key, additional_params)

    response_data = {
      message: translated_message,
      data: data
    }

    render json: response_data, status: status
  end

  # Mute responses
  def render_mute(data, status = :ok)
    response_data = {
      mute: data
    }
    render json: response_data, status: status
  end

  # reset_password_token responses
  def render_reset_password_token(data, status = :ok)
    response_data = {
      reset_password_token: data
    }
    render json: response_data, status: status
  end

  # access_token responses
  def render_access_token(data, status = :ok)
    response_data = {
      access_token: data
    }
    render json: response_data, status: status
  end

  # generate_access_token responses
  def render_generate_access_token(data, status = :ok)
    response_data = {
      message: data
    }
    render json: response_data, status: status
  end
end
