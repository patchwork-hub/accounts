# frozen_string_literal: true

# Pre-load starter pack data into cache on application startup
# This reduces first-request latency by warming the cache
Rails.application.config.after_initialize do
  # Only preload in production/staging to avoid slowing down development
  next unless Rails.env.production? || Rails.env.staging?

  # Run in a background thread to not block application startup
  Thread.new do
    begin
      # Wait a bit for the application to fully initialize
      sleep 5

      # Namespace sources to preload
      namespaces = %w[twt thebristolcable findout]

      Rails.logger.info "[StarterPacks] Pre-loading starter pack data into cache..."

      namespaces.each do |namespace|
        # Preload the list file for this namespace
        list_file = "#{namespace}/starter_pack_list.json"
        file_path = Accounts::Engine.root.join('config', 'data', list_file)

        next unless File.exist?(file_path)

        # Build cache key consistent with controller
        cache_key = "starter_pack_#{namespace}_#{list_file.gsub('/', '_').gsub('.json', '')}"

        # Load into cache
        Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          JSON.parse(File.read(file_path))
        end

        Rails.logger.info "[StarterPacks] Preloaded #{namespace} list into cache"
      rescue StandardError => e
        Rails.logger.error "[StarterPacks] Failed to preload #{namespace}: #{e.message}"
      end

      Rails.logger.info "[StarterPacks] Cache pre-loading complete"
    rescue StandardError => e
      Rails.logger.error "[StarterPacks] Cache pre-loading failed: #{e.message}"
    end
  end
end
