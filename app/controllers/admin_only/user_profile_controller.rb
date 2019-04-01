module AdminOnly

  class UserProfileController < ApplicationController

    before_action :authorize_admin
    before_action :get_user

    def edit
      render 'devise/registrations/edit', admin_action: true
    end

    def update
      if @app_configuration.update(app_config_params)
        redirect_to root_path, notice: t('.success')
      else
        flash.now[:alert] = t('.error')
        render :edit
      end
    end

    private

    def authorize_admin
      authorize AdminOnly::AppConfiguration
    end

    def get_app_configuration
      @user = User.find(params[:id])
    end

    def get_params
      params.require(:user).permit(:first_name, :last_name, :email, :password,
                                   :password_confirmation, :membership_number,
                                   shf_application_attributes: [ :contact_email ])
    end
  end

end
