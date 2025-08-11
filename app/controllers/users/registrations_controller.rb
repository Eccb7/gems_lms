class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def configure_sign_up_params
    # Only allow students to register through public signup
    # Remove role from permitted parameters and force it to 'student'
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :phone, :date_of_birth, :bio ])
  end

  def build_resource(hash = {})
    # Force all public registrations to be students
    hash[:role] = "student"
    super(hash)
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :phone, :date_of_birth, :bio)
  end
end
