require 'rest-client'
require 'json'

class SpotifyController < ApplicationController
  def login
    client_id = ENV['SPOTIFY_CLIENT_ID']
    redirect_url = callback_url
    scope = 'playlist-modify-private  user-read-private'
    spotify_url ="https://accounts.spotify.com/authorize?client_id=#{client_id}&response_type=code&redirect_uri=#{redirect_url}&scope=#{scope}"

    # 外部ホストへのリダイレクを許可するオプションを使用
    redirect_to spotify_url, allow_other_host: true
  end

  def callback
    code = params[:code]
    client_id = ENV['SPOTIFY_CLIENT_ID']
    client_secret = ENV['SPOTIFY_CLIENT_SECRET']
    redirect_url = callback_url

    response = RestClient.post('https://accounts.spotify.com/api/token', {
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: redirect_url,
      client_id: client_id,
      client_secret: client_secret
    },{
      Accept: 'application/json'
    })

    response_data = JSON.parse(response.body)
    access_token = response_data['access_token']
    refresh_token = response_data['refresh_token']

    # アクセストークンとリフレッシュトークンをセッションに保存
    session[:spotify_access_token] = access_token
    session[:spotify_refresh_token] = refresh_token

    flash[:success] = 'ログインしました'
    redirect_to app_top_path
  end

  private

  def callback_url
    "https://discover-music.fly.dev/spotify_callback"
  end
end
