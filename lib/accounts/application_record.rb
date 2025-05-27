# frozen_string_literal: true

module Accounts
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
