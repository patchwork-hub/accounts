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
        return 'Invalid credentials. You don\'t have access to login.' if user_info.nil?

        user = find_or_create_user(user_info)
        if user
          nil
        else
          'Failed to create user.'
        end
      else
        'Invalid credentials. Please try again.'
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

  def find_or_create_user(membership_data)
    byebug
    password = @params[:password]
    email = membership_data['email']
    firstname = membership_data['first_name'] || ''
    lastname = membership_data['last_name'] || ''

    if firstname.empty? && lastname.empty?
      username = email.split('@').first
    else
      username = "#{firstname}#{lastname}".strip
    end

    account = Account.where(username: username).first_or_initialize(username: username)
    account.save(validate: false)

    user = User.where(email: email).first_or_initialize(email: email, password: password, password_confirmation: password, confirmed_at: Time.now.utc, role: UserRole.find_by(name: ''), account: account, agreement: true, approved: true)
    user.save!
    user.approve!

    user
  end
end