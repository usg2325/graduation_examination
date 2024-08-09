class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create google_auth select]

  def new
    @user = User.new
  end

  def select; end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = 'ユーザー登録が完了しました'
      redirect_to login_path
    else
      flash[:error] = 'ユーザー登録に失敗しました'
      redirect_to sign_up_path
    end
  end

  def google_auth
    uid = session[:uid]
    provider = session[:provider]
    name = session[:name]
    email = session[:email]

    session.delete(:uid)
    session.delete(:provider)
    session.delete(:name)
    session.delete(:email)

    auth = Authentication.find_by(uid: uid, provider: provider)
    user = User.find_by(id: auth.user_id) if auth
    if user
      flash[:error] = 'すでにこのGoogleアカウントは登録されています'
      redirect_to login_path
    else
      password = SecureRandom.hex(16)
      @user = User.new(
        name: name,
        email: email,
        password: password,
        password_confirmation: password
      )

      if @user.save
        @authenticate = Authentication.new(
          user_id: @user.id,
          uid: uid,
          provider: provider,
        )

        if @authenticate.save
          flash[:success] = 'Googleアカウントでのユーザー登録が完了しました'
          redirect_to login_path
        else
          flash[:error] = 'ユーザー登録に失敗しました'
          redirect_to select_sign_up_path
        end
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
