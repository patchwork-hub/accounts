# frozen_string_literal: true

module Accounts::Api::V1
  class UserLocalesController < Api::BaseController
    include Accounts::Concerns::ApiResponseHelper
    
    before_action :require_user!
    before_action -> { doorkeeper_authorize! :read, :write }


    # POST /api/v1/user_locale/create
    # Saves the user's locale preference to database using 'lang' parameter
    def create
      locale = locale_params[:lang]&.to_sym
      unless I18n.available_locales.include?(locale)
        render_errors('api.errors.invalid_request', :bad_request, {
          available_locales: I18n.available_locales
        })
        return
      end

      # Update user's locale preference
      if current_user.update(locale: locale.to_s)
        I18n.locale = locale
        render_success({
          locale: I18n.locale,
          message: I18n.t('api.messages.updated')
        })
      else
        render_validation_errors(current_user.errors)
      end
    end

    private

    def locale_params
      params.permit(:lang)
    end
  end
end
