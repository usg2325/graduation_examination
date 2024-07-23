class GoogleController < ApplicationController
  skip_before_action :require_login, only: %i[create]

  def create
    user_info = request.env['omniauth.auth']

    state = request.env['omniauth.params']['state']

    uid = user_info[:uid]
    provider = user_info[:provider]
    name = user_info[:info][:name]
    email = user_info[:info][:email]

    session[:uid] = uid
    session[:provider] = provider

    if state == 'signup'
      session[:name] = name
      session[:email] = email
      redirect_to google_signup_path
    elsif state == 'login'
      redirect_to google_login_path
    else
      redirect_to root_path, alert: "Invalid authentication type."
    end
  end

end
