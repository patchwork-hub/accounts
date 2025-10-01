# frozen_string_literal: true

require 'googleauth'
require 'httparty'

class FirebaseNotificationService
  include HTTParty

  BASE_URL = case ENV['LOCAL_DOMAIN']
    when 'channel.org'
      'https://fcm.googleapis.com/v1/projects/patchwork-279c9/messages:send'
    when 'mo-me.social'
      'https://fcm.googleapis.com/v1/projects/mome-379ae/messages:send'
    when 'patchwork.io'
      'https://fcm.googleapis.com/v1/projects/patchwork-demo/messages:send'
    when 'newsmast.social', 'backend.newsmast.org'
      BASE_URL = 'https://fcm.googleapis.com/v1/projects/newsmast-e9c24/messages:send'
    when 'staging.patchwork.online'
      nil
    when 'qlub.channel.org'
      nil
    when 'thebristolcable.social'
      'https://fcm.googleapis.com/v1/projects/bristolcable-d0b14/messages:send'
    else
      nil # Development enviroment
    end

    FILE_NAME = case ENV['LOCAL_DOMAIN']
    when 'channel.org'
      'fcm_acc_service.json'
    when 'mo-me.social'
      'fcm_mo_me_service.json'
    when 'patchwork.io'
      'patchwork-demo-firebase-adminsdk-fbsvc-4b862033c1.json'
    when 'newsmast.social', 'backend.newsmast.org'
      'fcm_newsmast_service.json'
    when 'staging.patchwork.online'
      nil
    when 'qlub.channel.org'
      nil
    when 'thebristolcable.social'
      'bristolcable-d0b14-firebase.json'
    else
      nil # Development enviroment
    end

  def self.send_notification(token, title, body, data = {})
    # Path to your service account JSON file
    service_account_file = Rails.root.join('config', FILE_NAME)
    unless File.exist?(service_account_file)
      Rails.logger.error("Service account file not found at #{service_account_file}")
      return nil
    end

    # Define the required scope
    scope = 'https://www.googleapis.com/auth/firebase.messaging'

    # Authenticate and get the token
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(service_account_file),
      scope: scope
    )

    # Fetch the access token
    access_token = authorizer.fetch_access_token!['access_token']

    Rails.logger.info("access_token: #{access_token}")

    return nil if access_token.blank?

    headers = {
      'Authorization' => "Bearer #{access_token}",
      'Content-Type' => 'application/json',
    }

    payload = {
      message: {
        token: token,
        notification: {
          title: title,
          body: body,
        },
        data: data,
      },
    }.to_json
    response = post(BASE_URL, headers: headers, body: payload)

    Rails.logger.error("Error sending notification: #{response.body}") unless response.success?

    response
  rescue StandardError => e
    Rails.logger.error("Exception sending notification: #{e.message}")
    nil
  end
end
