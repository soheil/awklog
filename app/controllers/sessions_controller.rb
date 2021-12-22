class SessionsController < Devise::SessionsController
  layout 'tabler'
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:name, :email])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :company, :phone, :password, :password_confirmation, :user_type]) 
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password, :password_confirmation, :current_password])
  end
end
