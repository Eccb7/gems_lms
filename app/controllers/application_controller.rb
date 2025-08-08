class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions

  before_action :authenticate_user!, unless: :public_access_allowed?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user

  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: "You are not authorized to access this page."
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :phone, :date_of_birth, :bio, :role ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :phone, :date_of_birth, :bio, :avatar ])
  end

  def set_current_user
    Current.user = current_user if user_signed_in?
  end

  def redirect_based_on_role
    case current_user.role
    when "admin"
      redirect_to admin_dashboard_path
    when "instructor"
      redirect_to instructor_dashboard_path
    when "student"
      redirect_to student_dashboard_path
    else
      redirect_to root_path
    end
  end

  def require_admin
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end

  def require_instructor_or_admin
    redirect_to root_path, alert: "Access denied." unless current_user&.can_create_courses?
  end

  private

  def public_access_allowed?
    # Allow access to Devise controllers (sign in, sign up, etc.)
    return true if devise_controller?

    # Allow access to specific public pages
    public_actions = {
      'pages' => ['landing', 'about', 'contact', 'privacy', 'terms'],
      'courses' => ['index', 'show'],
      'categories' => ['index', 'show'],
      'rails/health' => ['show'],
      'rails/pwa' => ['service_worker', 'manifest']
    }

    controller_name = params[:controller]
    action_name = params[:action]

    public_actions[controller_name]&.include?(action_name)
  end
end
