# frozen_string_literal: true

module Accounts::Overrides::HomeExtendedTimeline
  DEFAULT_STATUSES_LIMIT = 20
    def home_statuses
      account_home_feed.get(
        limit_param(DEFAULT_STATUSES_LIMIT),
        params[:max_id],
        params[:since_id],
        params[:min_id],
        current_account,
        truthy_param?(:exclude_directs),
        truthy_param?(:exclude_followed_tags),
        truthy_param?(:exclude_replies)
      )
    end
end