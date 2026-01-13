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
    BristolcableLoginService.new(@params).login if ENV.fetch('LOCAL_DOMAIN', nil) == 'thebristolcable.social'
  end

  private

  def handle_web_login
    user = fetch_user_credentials
    if user.nil? || user&.confirmed_at.nil?
      return I18n.t('errors.unauthorized_access')
    end

    unless %w[UserAdmin HubAdmin].include?(user.role&.name)
      readable_role = user.role&.name&.gsub(/([a-z])([A-Z])/, '\1 \2')&.downcase&.capitalize
      return I18n.t('errors.unauthorized_access')
    end

    nil
  end

  def fetch_user_credentials
    User.find_by(email: @params[:username])
  end

  def fetch_channel_credentials(user)
    return unless Object.const_defined?('Accounts::CommunityAdmin')

    if defined?(Accounts::CommunityAdmin) && Accounts::CommunityAdmin.respond_to?(:find_by)
      Accounts::CommunityAdmin.joins(:community).find_by(
        account_id: user.account_id,
        is_boost_bot: true,
        account_status: Accounts::CommunityAdmin.account_statuses['active'],
        community: { deleted_at: nil }
      )
    end
  end

  def channel_active?(user)
    return false unless Object.const_defined?('Accounts::CommunityAdmin')

    return false unless defined?(Accounts::CommunityAdmin) && Accounts::CommunityAdmin.respond_to?(:find_by)

    community_admin = Accounts::CommunityAdmin.find_by(account_id: user.account_id, is_boost_bot: true)
    return true if community_admin.nil? || community_admin&.account_status == Accounts::CommunityAdmin.account_statuses['active']

    return true if community_admin&.community&.deleted_at.nil?

    false
  end

  def handle_web_login
    return nil if client_credentials?

    user = fetch_user_credentials
    return I18n.t('errors.unauthorized_access') if user.nil? || user&.confirmed_at.nil?

    return I18n.t('errors.invalid_credentials') unless user.role&.name.eql?('UserAdmin') || user.role&.name.eql?('HubAdmin') || user.role&.name.eql?('MasterAdmin')

    return I18n.t('errors.channel_not_created') unless channel_active?(user)

    nil
  end

  def handle_app_login
    user = grant_password? ? fetch_user_credentials : fetch_access_token_grant
    return I18n.t('errors.unauthorized_access') if user.nil?

    community_admin = fetch_channel_credentials(user)
    return I18n.t('errors.channel_not_created') if community_admin.nil?

    return I18n.t('errors.account_deleted') if community_admin&.account_status == 'deleted'

    return I18n.t('api.errors.unauthorized') unless valid_permissions?(community_admin, user)
    nil
  end

  def fetch_channel_credentials(user)
    return nil unless Object.const_defined?('Accounts::CommunityAdmin')

    return nil unless defined?(Accounts::CommunityAdmin) && Accounts::CommunityAdmin.respond_to?(:find_by)

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