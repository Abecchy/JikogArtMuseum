class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  def new; end

  def create
    @user = User.find_by(email: params[:email])
    @user&.deliver_reset_password_instructions!
    redirect_to root_path, success: t('.success')
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)
    not_authenticated if @user.blank?
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)
    return not_authenticated if @user.blank?

    @user.password_confirmation = params[:user][:password_confirmation]

    if params[:user][:password].empty?
      @user.errors.add(:password, "を入力してください")
      flash.now[:danger] = t('.failure')
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
      @user.change_password(params[:user][:password])
      redirect_to login_path, success: t('.success')
    else
      flash.now[:danger] = t('.failure')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
