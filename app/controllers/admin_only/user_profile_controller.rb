module AdminOnly

  class UserProfileController < ApplicationController

    before_action :authorize_admin
    before_action :get_user

    def become
      return unless current_user.admin?

      bypass_sign_in(User.find(params[:id]))

      helpers.flash_message(:warn, t('.have_become', user_id: @user.id))

      redirect_to user_path(params[:id])
    end

    def edit
    end

    def update
      if @user.update(get_params)
        helpers.flash_message(:notice, t('.success'))
      else
        helpers.flash_message(:alert, t('.error'))
      end
      render :edit
    end

    private

    def authorize_admin
      authorize AdminOnly::AppConfiguration
    end

    def get_user
      @user = User.find(params[:id])
    end

    def get_params
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      params.require(:user).permit(:first_name, :last_name, :email, :password,
                                   :password_confirmation, :membership_number,
                                   shf_application_attributes: [ :contact_email ])
    end
  end

end
