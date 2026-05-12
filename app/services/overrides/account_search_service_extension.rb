# frozen_string_literal: true

module Overrides::AccountSearchServiceExtension
  def call(query, account = nil, options = {})
    results = super

    if options[:local_only]
      results.select(&:local?)
    else
      results
    end
  end
end
