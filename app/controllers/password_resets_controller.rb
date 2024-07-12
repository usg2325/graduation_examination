class PasswordResetsController < ApplicationController
  skip_before_action :require_login, only: %i[create edit update new]

  def create
    @user = User.find_by(email: params[:email])
    @user&.deliver_reset_password_instructions!
    
    flash[:success] = "パスワードリセット手順を送信しました"
    redirect_to login_path
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

    if params[:user][:password].blank?
      flash[:error] = "パスワードを入力してください"
      redirect_to edit_password_reset_path
      return
    end

    if params[:user][:password] != params[:user][:password_confirmation]
      flash[:error] = "パスワードが一致しません"
      redirect_to edit_password_reset_path
      return
    end

    if @user.change_password(params[:user][:password])
      flash[:success] = "パスワードを変更しました"
      redirect_to login_path
    else
      flash.now[:error] = "パスワードの変更に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def new; end
end
