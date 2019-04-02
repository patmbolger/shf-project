module AdminOnly

  class UserProfileController < ApplicationController

    before_action :authorize_admin
    before_action :get_user

    def become
      return unless current_user.admin?

      bypass_sign_in(User.find(params[:id]))

      helpers.flash_message(:warn,
        "You are now acting as user with id #{params[:id]}")

      redirect_to user_path(params[:id])
    end

    def edit
      render 'devise/registrations/edit', locals: { admin_action: true }
    end

    def update
      if @user.update(get_params)
        redirect_to @user, notice: t('.success')
      else
        helpers.flash_message(:alert, t('.error'))

        @user.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }

        render :show
      end
    end

    private

    def authorize_admin
      authorize AdminOnly::AppConfiguration
    end

    def get_user
      @user = User.find(params[:id])
    end

    def get_params
      params.require(:user).permit(:first_name, :last_name, :email, :password,
                                   :password_confirmation, :membership_number,
                                   shf_application_attributes: [ :contact_email ])
    end
  end

end
