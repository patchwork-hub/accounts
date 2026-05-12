# frozen_string_literal: true

module Accounts::Concerns::SearchControllerExtension
  extend ActiveSupport::Concern

  private

  def combined_search_params
    super.merge(local_only: truthy_param?(:local_only))
  end
end
