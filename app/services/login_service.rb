# frozen_string_literal: true

class LoginService
  def initialize(params)
    @params = params
  end

  def channel_login
    error_message = if ENV.fetch('MAIN_CHANNEL', nil) != nil  && ENV.fetch('MAIN_CHANNEL', nil) != 'false'
      web_login? ? handle_web_login : handle_app_login
    end
  end

  def non_channel_login
    nil
  end

  def bristol_cable_login
    BristolcableLoginService.new(@params).login if ENV.fetch('LOCAL_DOMAIN', nil) == 'thebristolcable.social' || Rails.env.development?
  end

  private

  def handle_web_login
    user = fetch_user_credentials
    if user.nil? || user&.confirmed_at.nil?
      return 'You don\'t have access to login.'
    end

    unless %w[UserAdmin HubAdmin].include?(user.role&.name)
      readable_role = user.role&.name&.gsub(/([a-z])([A-Z])/, '\1 \2')&.downcase&.capitalize
      return "#{readable_role} isn\'t allowed to access login."
    end

    nil
  end

  def fetch_user_credentials
    User.find_by(email: @params[:username])
  end

  def handle_app_login
    user = grant_password? ? fetch_user_credentials : fetch_access_token_grant
    if user.nil? || user&.confirmed_at.nil?
      return 'You don\'t have access to login.' 
    end

    community_admin = fetch_channel_credentials(user)
    if community_admin.nil?
      return 'Invalid credentials. Please make sure you\'ve created a channel.' 
    end

    if community_admin&.account_status == 'deleted'
      return 'Your account has already deleted.'
    end

    unless valid_permissions?(community_admin, user)
      return 'Invalid credentials or insufficient permissions to access login.'
    end

    nil
  end

  def fetch_channel_credentials(user)
    CommunityAdmin.find_by(account_id: user.account_id, is_boost_bot: true, account_status: CommunityAdmin.account_statuses["active"])
  end

  def web_login?
    truthy_param?(@params[:is_web_login])
  end

  def valid_permissions?(community_admin, user)
    belong_any_channel?(community_admin) &&
      (
        (community_admin&.role.eql?('OrganisationAdmin') && user.role&.name.eql?('OrganisationAdmin')) ||
        (community_admin&.role.eql?('UserAdmin') && user.role&.name.eql?('UserAdmin')) ||
        (community_admin&.role.eql?('HubAdmin') && user.role&.name.eql?('HubAdmin'))
      )
  end

  def belong_any_channel?(community_admin)
    return false unless community_admin&.patchwork_community_id.present?

    Community.exists?(
      id: community_admin.patchwork_community_id,
      visibility: Community.visibilities.keys
    )
  end

  def grant_password?
    @params[:grant_type] == 'password'
  end

  def client_credentials?
    @params[:grant_type] == 'client_credentials'
  end

  def fetch_access_token_grant
    access_token_grant = Doorkeeper::AccessGrant.find_by(token: @params[:code])
    User.find_by(id: access_token_grant&.resource_owner_id)
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(key)
  end
end