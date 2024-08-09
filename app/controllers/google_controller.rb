class GoogleController < ApplicationController
  skip_before_action :require_login

  def oauth
    session[:state] = auth_params[:state]
    login_at(auth_params[:provider])
  end

  def callback
    provider = auth_params[:provider]
    state = session[:state]
    session.delete(:state)

    sorcery_fetch_user_hash(provider)
    session[:uid] = @user_hash[:uid]
    session[:provider] = provider

    if state == 'signup'
      user_info = @user_hash[:user_info]
      session[:email] = user_info['email']
      session[:name] = user_info['name']
      redirect_to google_signup_path
    elsif state == 'login'
      redirect_to google_login_path
    else
      redirect_to root_path, alert: "Invalid authentication type."
    end
  end

  private

  def auth_params
    params.permit(:code, :provider, :state)
  end
end
