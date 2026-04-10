# lib/tasks/fetch_s3_images.rake
require 'aws-sdk-s3'

namespace :s3 do
  desc "Fetch avatar and banner images for newsmast channel IDs from S3"
  task fetch_newsmast_images: :environment do
    # ===== 1. Get newsmast channel IDs =====
    newsmast_channel_ids = Accounts::Community
      .where(channel_type: Accounts::Community.channel_types['newsmast'])
      .pluck(:id)
      .map(&:to_s)   # convert to string for S3 path comparison

    if newsmast_channel_ids.empty?
      puts "No newsmast channel IDs found. Exiting."
      exit
    end

    puts "Found #{newsmast_channel_ids.count} newsmast channel IDs: #{newsmast_channel_ids.inspect}"

    # ===== 2. S3 Configuration =====
    bucket_name = 'patchwork-prod'
    Aws.config.update(
      region: 'eu-west-2',
      credentials: Aws::Credentials.new(
        ENV['AWS_ACCESS_KEY_ID'],
        ENV['AWS_SECRET_ACCESS_KEY']
      )
    )
    resource = Aws::S3::Resource.new
    bucket = resource.bucket(bucket_name)

    # ===== 3. Helper to fetch images for a given prefix =====
    def fetch_images_for_prefix(bucket, prefix, allowed_ids)
      images_hash = Hash.new { |h, k| h[k] = [] }
      bucket.objects(prefix: prefix).each do |obj|
        key = obj.key
        relative_path = key.sub(prefix, '')
        parts = relative_path.split('/')
        id = parts[0]
        next unless allowed_ids.include?(id)

        filename = parts.last
        next unless filename.match?(/\.(jpg|jpeg|png|gif)$/i)

        images_hash[id] << filename unless images_hash[id].include?(filename)
      end
      images_hash
    end

    # ===== 4. Fetch avatar images =====
    avatar_prefix = 'communities/avatar_images/000/000/'
    puts "Fetching avatar images from s3://#{bucket_name}/#{avatar_prefix} ..."
    avatar_images_hash = fetch_images_for_prefix(bucket, avatar_prefix, newsmast_channel_ids)

    # ===== 5. Fetch banner images =====
    banner_prefix = 'communities/banner_images/000/000/'
    puts "Fetching banner images from s3://#{bucket_name}/#{banner_prefix} ..."
    banner_images_hash = fetch_images_for_prefix(bucket, banner_prefix, newsmast_channel_ids)

    # ===== 6. Output results =====
    puts "\n✅ Avatar images by ID:"
    if avatar_images_hash.empty?
      puts "  No avatar images found for the given IDs."
    else
      avatar_images_hash.each do |id, filenames|
        puts "  ID #{id}: #{filenames.join(', ')}"
      end
    end

    puts "\n✅ Banner images by ID:"
    if banner_images_hash.empty?
      puts "  No banner images found for the given IDs."
    else
      banner_images_hash.each do |id, filenames|
        puts "  ID #{id}: #{filenames.join(', ')}"
      end
    end

    # ===== 7. (Optional) Store or use the hashes =====
    # You can now access avatar_images_hash and banner_images_hash elsewhere
    # e.g., assign to a constant, cache in Redis, or update database models.
    # For demonstration, we'll store them in a global variable (not recommended for production)
    # Optional: Store in database or cache

    avatar_images_hash.each do |id, filenames|
      community = Accounts::Community.find_by(id: id)
      community.update(avatar_image_file_name: filenames.last) if community
      puts "Updated community ID #{id} with avatar image: #{filenames.last}" if community
    end

    banner_images_hash.each do |id, filenames|
      community = Accounts::Community.find_by(id: id)
      community.update(banner_image_file_name: filenames.last) if community
      puts "Updated community ID #{id} with banner image: #{filenames.last}" if community
    end

    puts "\n✅ Hashes stored in $newsmast_avatar_images and $newsmast_banner_images"
  end
end
