require 'json'
require 'rest-client'

class ApplicationController < ActionController::Base
  before_action :require_login

  private

  def not_authenticated
    flash[:warning] = 'ログインしてください'
    redirect_to login_path
  end

  def ensure_spotify_token_valid
    unless spotify_token_valid?
      refresh_spotify_token
    end
  end
  
  def spotify_token_valid?
    begin
      response = RestClient.get('https://api.spotify.com/v1/me', {
        Authorization: "Bearer #{session[:spotify_access_token]}"
      })
      response.code == 200
    rescue RestClient::BadRequest => e
      Rails.logger.error("Bad Request: #{e.response}")
      false
    rescue RestClient::Unauthorized, RestClient::Forbidden
      false
    end
  end

  def refresh_spotify_token
    client_id = ENV['SPOTIFY_CLIENT_ID']
    client_secret = ENV['SPOTIFY_CLIENT_SECRET']
    refresh_token = session[:spotify_refresh_token]

    auth_header = Base64.strict_encode64("#{client_id}:#{client_secret}")

    response = RestClient.post('https://accounts.spotify.com/api/token', {
      grant_type: 'refresh_token',
      refresh_token: refresh_token
    }, {
      Authorization: "Basic #{auth_header}",
      Content_Type: 'application/x-ww-form-urlencoded'
    })

    response_data = JSON.parse(response.body)
    access_token = response_data['access_token']

    # アクセストークンをセッションに保存
    session[:spotify_access_token] = access_token
  end
end
