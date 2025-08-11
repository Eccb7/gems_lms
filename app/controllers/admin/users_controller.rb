class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [ :show, :edit, :update, :destroy, :activate, :deactivate, :change_role ]

  def index
    @users = User.all
                 .includes(:enrollments, :courses)
                 .order(:created_at)
                 .page(params[:page])
                 .per(20)

    # Filter by role if specified
    @users = @users.where(role: params[:role]) if params[:role].present?

    # Search functionality
    if params[:search].present?
      @users = @users.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
        "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"
      )
    end
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.password = params[:user][:password] if params[:user][:password].present?
    @user.password_confirmation = params[:user][:password_confirmation] if params[:user][:password_confirmation].present?

    if @user.save
      redirect_to admin_users_path, notice: "#{@user.role.capitalize} created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Handle password updates
    if params[:user][:password].present?
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      # Remove password fields if empty
      user_update_params = user_params.except(:password, :password_confirmation)
      if @user.update(user_update_params)
        redirect_to admin_user_path(@user), notice: "User updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    if @user.admin? && User.admin.count <= 1
      redirect_to admin_users_path, alert: "Cannot delete the last admin user."
    else
      @user.destroy
      redirect_to admin_users_path, notice: "User deleted successfully."
    end
  end

  def activate
    @user.update(active: true)
    redirect_to admin_users_path, notice: "User activated successfully."
  end

  def deactivate
    if @user.admin? && User.admin.where(active: true).count <= 1
      redirect_to admin_users_path, alert: "Cannot deactivate the last active admin user."
    else
      @user.update(active: false)
      redirect_to admin_users_path, notice: "User deactivated successfully."
    end
  end

  def change_role
    old_role = @user.role
    new_role = params[:role]

    if new_role.in?([ "student", "instructor", "admin" ])
      @user.update(role: new_role)
      redirect_to admin_users_path, notice: "User role changed from #{old_role} to #{new_role}."
    else
      redirect_to admin_users_path, alert: "Invalid role specified."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :date_of_birth, :bio, :role, :active, :password, :password_confirmation)
  end
end
