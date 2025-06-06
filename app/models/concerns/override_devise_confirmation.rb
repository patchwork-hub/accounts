module OverrideDeviseConfirmation
  extend ActiveSupport::Concern

  included do
    before_create :skip_confirmation_if_needed
  end

  private

  def skip_confirmation_if_needed
    skip_confirmation!
  end
end 