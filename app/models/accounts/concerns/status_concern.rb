module Accounts::Concerns::StatusConcern
  extend ActiveSupport::Concern

  included do
    scope :tagged_without, ->(tag_ids) {
      return all if tag_ids.blank?
  
      where.not(id: Status.joins(:statuses_tags).where(statuses_tags: { tag_id: tag_ids }).select(:id))
    }
  end
end
