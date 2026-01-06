require 'httparty'

class BristolcableLoginService
  include HTTParty
  BASE_URL = 'https://membership.thebristolcable.org'

  def initialize(params)
    @params = params
  end

  def login
    user = fetch_user_credentials
    if user.nil? || user&.confirmed_at.nil?
      result = authenticate_with_membership_service
      if result
        cookies = result[:cookies]
        response_data = result[:response]
        user_info = fetch_user_information(cookies)
        if user_info.nil?
          return 'Please try again. Invalid credentials from beebee.io'
        else
          data = { firstname: user_info['firstname'], lastname: user_info['lastname'] }
          return "Please register account in local. data: #{data}"
        end
      else
        'Please try again. Invalid credentials from beebee.io'
      end
    else
      nil
    end
  end

  private

  def fetch_user_credentials
    User.find_by(email: @params[:username])
  end

  def authenticate_with_membership_service
    headers = {
      'Content-Type' => 'application/json',
    }
    payload = {
      email: @params[:username],
      password: @params[:password]
    }.to_json
    response = HTTParty.post("#{BASE_URL}/api/1.0/auth/login", headers: headers, body: payload)
    if response.code == 204
      {
        cookies: response.headers['Set-Cookie'],
        response: response.parsed_response
      }
    else
      nil
    end
  rescue StandardError => e
    return "Error connecting to membership service: #{e.message}"
  end

  def fetch_user_information(cookies)
    headers = {
      'Cookie' => cookies,
      'Content-Type' => 'application/json',
    }
    response = HTTParty.get("#{BASE_URL}/api/1.0/contact/me", headers: headers)
    if response.code == 200
      response.parsed_response
    else
      nil
    end
  rescue StandardError => e
    return "Error connecting to membership service: #{e.message}"
  end
end