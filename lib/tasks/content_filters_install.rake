# frozen_string_literal: true

require 'csv'

namespace :domain_block do
  desc "Import domain_block.csv into domain_blocks table in chunks of 500"
  task import: :environment do
    file_path = Rails.root.join("public", "csv", "domain_blocks.csv")

    unless File.exist?(file_path)
      puts "CSV file not found: #{file_path}"
      exit
    end

    puts "Starting bulk import (500 per batch) from #{file_path}..."

    marker      = " (Imported from CSV Rake Task)"
    csv_domains = Set.new
    rows        = []

    # First pass: read CSV into memory and collect domains
    CSV.foreach(file_path, headers: true) do |row|
      domain = row["#domain"]&.strip
      next if domain.blank?

      csv_domains << domain
      rows << row
    end

    # Load only existing domains that are in the current CSV
    existing_domains = DomainBlock.where(domain: csv_domains.to_a).pluck(:domain).to_set
    new_records      = []

    # Build new records only for domains not yet present
    rows.each do |row|
      domain = row["#domain"]&.strip
      next if domain.blank? || existing_domains.include?(domain)

      base_public_comment = row["#public_comment"]&.strip

      customized_public_comment =
        if base_public_comment.present?
          "#{base_public_comment} (Imported from CSV Rake Task)"
        else
          " (Imported from CSV Rake Task)"
        end

      new_records << {
        domain:         domain,
        severity:       row.fetch('#severity', :suspend),
        reject_media:   row.fetch('#reject_media', false),
        reject_reports: row.fetch('#reject_reports', false),
        public_comment: customized_public_comment,
        obfuscate:      row.fetch('#obfuscate', false)
      }
    end

    ActiveRecord::Base.transaction do
      # Insert in batches of 500
      new_records.each_slice(500) do |batch|
        DomainBlock.insert_all(batch)
        puts "Inserted #{batch.size} records..."
      end

      # Delete CSV-imported blocks whose domains are no longer present in the CSV
      deleted_count = DomainBlock
                        .where("public_comment LIKE ?", "%#{marker}%")
                        .where.not(domain: csv_domains.to_a)
                        .delete_all

      puts "Deleted #{deleted_count} old CSV-imported domain blocks"
    end

    puts "Bulk import completed. Total new: #{new_records.size}"
  end
end
