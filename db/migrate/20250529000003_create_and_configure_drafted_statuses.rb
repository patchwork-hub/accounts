# frozen_string_literal: true

require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class CreateAndConfigureDraftedStatuses < ActiveRecord::Migration[7.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    unless table_exists?(:patchwork_drafted_statuses)
      begin
        create_table :patchwork_drafted_statuses do |t|
          t.belongs_to :account, foreign_key: { on_delete: :cascade }
          t.jsonb :params
          t.timestamps
        end
      rescue StandardError => e
        Rails.logger.error("Failed to create patchwork_drafted_statuses table: #{e.message}")
        raise
      end
    else
      Rails.logger.info("Table patchwork_drafted_statuses already exists, skipping creation")
    end

    unless column_exists?(:media_attachments, :patchwork_drafted_status_id)
      begin
        safety_assured do
          add_reference :media_attachments, :patchwork_drafted_status, foreign_key: { on_delete: :nullify }, index: false
        end
        add_index :media_attachments, :patchwork_drafted_status_id, algorithm: :concurrently, name: 'index_media_attachments_on_patchwork_drafted_status_id'
      rescue StandardError => e
        Rails.logger.error("Failed to add patchwork_drafted_status_id to media_attachments: #{e.message}")
        raise
      end
    else
      Rails.logger.info("Column patchwork_drafted_status_id already exists in media_attachments, skipping addition")
    end

    begin
      update_index :media_attachments, 'index_media_attachments_on_patchwork_drafted_status_id', :patchwork_drafted_status_id, where: 'patchwork_drafted_status_id IS NOT NULL', algorithm: :concurrently
    rescue StandardError => e
      Rails.logger.error("Failed to update index on media_attachments: #{e.message}")
      raise
    end
  end

  def down
    begin
      update_index :media_attachments, 'index_media_attachments_on_patchwork_drafted_status_id', :patchwork_drafted_status_id, algorithm: :concurrently
    rescue StandardError => e
      Rails.logger.error("Failed to revert index on media_attachments: #{e.message}")
    end

    if column_exists?(:media_attachments, :patchwork_drafted_status_id)
      begin
        safety_assured do
          remove_reference :media_attachments, :patchwork_drafted_status, foreign_key: true, index: false
        end
      rescue StandardError => e
        Rails.logger.error("Failed to remove patchwork_drafted_status_id from media_attachments: #{e.message}")
      end
    end

    if table_exists?(:patchwork_drafted_statuses)
      begin
        drop_table :patchwork_drafted_statuses
      rescue StandardError => e
        Rails.logger.error("Failed to drop patchwork_drafted_statuses table: #{e.message}")
      end
    end
  end
end