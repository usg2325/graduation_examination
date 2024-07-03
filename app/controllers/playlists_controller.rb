class PlaylistsController < ApplicationController
  before_action :ensure_spotify_token_valid, only: %i[show destroy]
  before_action :set_playlist, only: %i[destroy]

  def select; end

  def index
    @user_playlist = Playlist.where(user: current_user).page(params[:page]).per(10)
    @playlist_ids = @user_playlist.map { |fa| fa.spotify_id }
  end

  def show
    @playlist = Playlist.find(params[:id])

    playlist_id = Playlist.find_by(id: @playlist).spotify_id

    #プレイリスト収録曲の確認
    playlist_items = RestClient.get(
      "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks",
      {
        Authorization: "Bearer #{session[:spotify_access_token]}",
        content_type: :json
      }
    )

    playlist_tracks = JSON.parse(playlist_items.body)

    playlist_item = []

    playlist_tracks['items'].each do |track|
      track_info = track['track']
      track_name = track_info['name']
      artist_name = track_info['artists'].map { |artist| artist['name'] }.join(', ')
      playlist_item << [track_name, artist_name]
    end

    @playlist_items = playlist_item
  end

  def destroy
    playlist_id = @playlist.spotify_id

    headers = {
      Authorization: "Bearer #{session[:spotify_access_token]}"
    }

    RestClient.delete("https://api.spotify.com/v1/playlists/#{playlist_id}/followers", headers)
    
    @playlist.destroy!
    flash[:success] = "プレイリストを削除しました"
    redirect_to playlists_path, status: :see_other
  end

  private
  
  def set_playlist
    @playlist = Playlist.find(params[:id])
  end
end
