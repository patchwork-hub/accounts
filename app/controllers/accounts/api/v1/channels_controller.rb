# frozen_string_literal: true

module Accounts::Api::V1
  class ChannelsController < Api::BaseController
    before_action :require_user!
    before_action -> { doorkeeper_authorize! :read, :write }
    # GET /api/v1/channels/starter_packs_channels
    # Returns the list of starter pack channels from JSON data
    def starter_packs_channels
      file_path = starter_pack_data_path('starter_pack_list.json')
      full_path = Accounts::Engine.root.join('config', 'data', file_path)
      
      # Return empty response if file doesn't exist
      unless File.exist?(full_path)
        render json: { data: [] } and return
      end

      # Set HTTP caching headers based on file modification time
      last_modified = File.mtime(full_path)
      if stale?(last_modified: last_modified, etag: "#{starter_pack_namespace}-#{last_modified.to_i}")
        starter_packs_channels = load_json_data(file_path)
        
        expires_in 5.minutes, public: true
        
        render json: { data: starter_packs_channels }
      end
    end

    # GET /api/v1/channels/:id/starter_packs_detail
    # Returns details of a specific starter pack channel including followers
    def starter_packs_detail
      channel_id = params[:id]
      list_file = starter_pack_data_path('starter_pack_list.json')
      list_path = Accounts::Engine.root.join('config', 'data', list_file)
      
      unless File.exist?(list_path)
        render json: { error: "Channel not found" }, status: :not_found and return
      end

      followers_file = starter_pack_data_path("starter_pack_#{channel_id}.json")
      followers_path = Accounts::Engine.root.join('config', 'data', followers_file)
      
      list_mtime = File.mtime(list_path)
      followers_mtime = File.exist?(followers_path) ? File.mtime(followers_path) : list_mtime
      last_modified = [list_mtime, followers_mtime].max
      
      if stale?(last_modified: last_modified, etag: "#{starter_pack_namespace}-#{channel_id}-#{last_modified.to_i}")
        starter_packs_channels = load_json_data(list_file)
        channel = starter_packs_channels.find { |ch| ch["id"] == channel_id }

        unless channel
          render json: { error: "Channel not found" }, status: :not_found and return
        end

        followers = load_json_data(followers_file)
        
        expires_in 5.minutes, public: true
        
        render json: {
          channel: channel,
          followers: followers
        }
      end
    end

    private

    def load_json_data(filename)
      cache_key = "starter_pack_#{starter_pack_namespace}_#{filename.gsub('/', '_').gsub('.json', '')}"
      
      Rails.cache.fetch(cache_key, expires_in: 1.hour) do
        file_path = Accounts::Engine.root.join('config', 'data', filename)
        
        next [] unless File.exist?(file_path)
        
        JSON.parse(File.read(file_path))
      end
    end

    def starter_pack_data_path(filename)
      File.join(starter_pack_namespace, filename)
    end

    # Determine the namespace/source for starter pack data
    def starter_pack_namespace
      source = params[:starter_pack_source]
      normalized_source = source.present? ? source.to_s.parameterize(separator: '') : nil

      case normalized_source
      when 'thebristolcable'
        'thebristolcable'
      when 'twt'
        'twt'
      when 'findout'
        'findout'
      else
        'twt'
      end
    end
  end
end
