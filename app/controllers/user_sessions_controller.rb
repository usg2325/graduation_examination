class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create google_auth]

  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_to guide_spotify_login_path
    else
      flash[:error] = 'メールアドレスまたはパスワードが間違っています'
      redirect_to login_path
    end
  end

  def google_auth
    uid = session[:uid]
    provider = session[:provider]

    session.delete(:uid)
    session.delete(:provider)

    auth = Authentication.find_by(uid: uid, provider: provider)
    user = User.find_by(id: auth.user_id) if auth
    if user
      auto_login(user)
      redirect_to guide_spotify_login_path
    else
      flash[:error] = 'このGoogleアカウントは登録されていません'
      redirect_to login_path
    end
  end

  def destroy
    logout
    flash[:success] = 'ログアウトしました'
    redirect_to root_path, status: :see_other
  end

  def guide_spotify_login; end

end
