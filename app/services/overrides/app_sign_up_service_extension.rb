module Overrides::AppSignUpServiceExtension
  include MoMeHelper

  def create_user!
    @user = User.create!(
      user_params.merge(created_by_application: @app, sign_up_ip: @remote_ip, password_confirmation: user_params[:password], account_attributes: account_params, invite_request_attributes: invite_request_params)
    )
    @user.skip_confirmation!
  end

  # def invite_request_params
  #   {
  #     text: mo_me_invite_text
  #   }
  # end

  # def mo_me_invite_text
  #   is_mo_me? ? "Signing up via Mo-Me App" : @params[:reason]
  # end
end
