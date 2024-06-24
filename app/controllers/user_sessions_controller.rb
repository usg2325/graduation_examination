class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

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

  def destroy
    logout
    flash[:success] = 'ログアウトしました'
    redirect_to root_path, status: :see_other
  end

  def guide_spotify_login; end

end
