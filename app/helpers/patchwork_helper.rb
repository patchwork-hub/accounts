# frozen_string_literal: true

module PatchworkHelper
  extend ActiveSupport::Concern

  def patchwork_table_exists?(table_name)
    ActiveRecord::Base.connection.data_source_exists?(table_name)
  rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad
    false
  end

  def patchwork_server_settings_exist?    
    return false unless patchwork_table_exists?('server_settings')

    return false unless Object.const_defined?('Accounts::ServerSetting') &&
                        defined?(Accounts::ServerSetting) &&
                        Accounts::ServerSetting.respond_to?(:find_by)

    true
  end

  def patchwork_community_admin_exist?
    return false unless patchwork_table_exists?('patchwork_communities_admins')

    return false unless Object.const_defined?('Accounts::CommunityAdmin') && defined?(Accounts::CommunityAdmin) && Accounts::CommunityAdmin.respond_to?(:find_by)
    
    true
  end
end
