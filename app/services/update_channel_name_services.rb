# frozen_string_literal: true

class UpdateChannelNameServices < BaseService
  require "httparty"

  def call(account, options = {})
    # The channel is already updated in the Dashboard when the avatar or banner is changed,
    # so we can skip the update if one of those has been changed.
    return if options[:skip_dashboard_profile]

    return unless Object.const_defined?('Accounts::CommunityAdmin')
    
    return unless defined?(Accounts::CommunityAdmin) && Accounts::CommunityAdmin.respond_to?(:find_by)

    instance_domain = Rails.env.development? ? nil : ENV.fetch('LOCAL_DOMAIN', nil)&.strip.presence
    dashboard_instance_url = ENV.fetch('DASHBOARD_INSTANCE_URL', nil)&.strip
    return if dashboard_instance_url.blank?

    url = "#{dashboard_instance_url}/api/v1/channels/change_boost_bot_profile"
    @opened_uploads = []

    community_admin = Accounts::CommunityAdmin.find_by(
      account_id: account.id,
      is_boost_bot: true,
      account_status: Accounts::CommunityAdmin.account_statuses['active']
    )
    return unless community_admin

    community = community_admin.community
    return unless community

    return unless community.channel_type == Accounts::Community.channel_types['channel_feed']

    avatar_file = normalize_upload(account.avatar)
    header_file = normalize_upload(account.header)

    body = {}
    body[:name] = account.display_name.b if account.display_name
    body[:description] = account.note.b if account.note
    body[:avatar] = avatar_file if avatar_file
    body[:banner] = header_file if header_file
    body[:instance_domain] = instance_domain if instance_domain
    body[:id] = community.slug if community

    HTTParty.patch(
      url,
      headers: {},
      body: body,
      multipart: body.key?(:avatar) || body.key?(:banner)
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "[UpdateChannelNameServices] Community update failed: #{e.record.class} - #{e.message}"
  ensure
    @opened_uploads&.each do |upload|
      upload.close if upload.respond_to?(:close) && !upload.closed?
    rescue IOError, Errno::EBADF
      nil
    end

    @opened_temp_paths&.each do |path|
      File.delete(path) if File.exist?(path)
    rescue StandardError
      nil
    end
  end

  private

    def normalize_upload(value)
      return nil if value.nil?

      return value if value.is_a?(File) || value.is_a?(Tempfile)

      if defined?(ActionDispatch::Http::UploadedFile) && value.is_a?(ActionDispatch::Http::UploadedFile)
        return value.tempfile
      end

      if defined?(Paperclip::Attachment) && value.is_a?(Paperclip::Attachment)
        return nil unless value.present?
        return nil if value.respond_to?(:exists?) && !value.exists?

        queued_file = value.queued_for_write[:original] if value.respond_to?(:queued_for_write)
        return queued_file if queued_file

        original_name = value.original_filename if value.respond_to?(:original_filename)
        original_name ||= "image_#{SecureRandom.hex(4)}.jpg"

        begin
          if defined?(Paperclip) && Paperclip.respond_to?(:io_adapters)
            adapter = Paperclip.io_adapters.for(value)
            
            require 'fileutils'
            tmp_dir = Rails.root.join('tmp', 'patchwork_uploads', SecureRandom.hex(8))
            FileUtils.mkdir_p(tmp_dir)
            tmp_file_path = File.join(tmp_dir, original_name)
            
            File.open(tmp_file_path, 'wb') do |f|
              f.write(adapter.read)
            end
            
            file = File.open(tmp_file_path, 'rb')
            
            @opened_uploads << file
            @opened_temp_paths ||= []
            @opened_temp_paths << tmp_file_path
            
            return file
          end
        rescue => e
          Rails.logger.error("Error creating temp upload file: #{e.message}")
          return nil
        end

        return nil
      end

      if value.is_a?(String) && File.exist?(value)
        file = File.open(value, "rb")
        @opened_uploads << file
        return file
      end

      raise ArgumentError, "Unsupported upload type: #{value.class}"
    end
end
