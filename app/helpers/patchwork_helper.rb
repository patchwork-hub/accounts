# frozen_string_literal: true

module PatchworkHelper
  extend ActiveSupport::Concern

  def patchwork_server_settings_exist?
    return false unless Object.const_defined?('Accounts::ServerSetting') && defined?(Accounts::ServerSetting)

    Accounts::ServerSetting.respond_to?(:table_exists?) && Accounts::ServerSetting.table_exists?
  end

  def patchwork_community_admin_exist?
    return false unless Object.const_defined?('Accounts::CommunityAdmin') && defined?(Accounts::CommunityAdmin)

    Accounts::CommunityAdmin.respond_to?(:table_exists?) && Accounts::CommunityAdmin.table_exists?
  end
end
