class PlaylistsController < ApplicationController
  before_action :ensure_spotify_token_valid, only: %i[show edit update destroy]
  before_action :set_playlist, only: %i[show edit update destroy]

  def select; end

  def index
    @user_playlist = Playlist.where(user: current_user).page(params[:page]).per(10)
    @playlist_ids = @user_playlist.map { |fa| fa.spotify_id }
  end

  def show
    set_playlist_items
  end

  def edit
    @playlist_name = @playlist.name
    set_playlist_items

  end

  def update
    playlist_params = set_playlist_params
    playlist_name = playlist_params[:playlist_name]
    public_status = playlist_params[:public_status] == 'public'

    @playlist.update(name: playlist_name)

    playlist_id = @playlist.spotify_id

    playlist_update = RestClient.put(
      "https://api.spotify.com/v1/playlists/#{playlist_id}",
      {
        name: playlist_name,
        public: public_status
      }.to_json,
      {
        Authorization: "Bearer #{session[:spotify_access_token]}",
        content_type: :json,
        accept: :json
      }
    )

    flash[:success] = "プレイリストを変更しました"
    redirect_to playlist_path(@playlist)

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

  def set_playlist_params
    params.require(:playlist).permit(:playlist_name, :public_status)
  end

  def set_playlist_items
    playlist_id = Playlist.find_by(id: @playlist).spotify_id

    # プレイリストがプロフィールで公開されているかを確認
    user_playlists = RestClient.get(
      "https://api.spotify.com/v1/me/playlists",
      {
        Authorization: "Bearer #{session[:spotify_access_token]}",
        content_type: :json
      }
    )

    playlists_info = JSON.parse(user_playlists.body)
    playlist_ids = playlists_info['items'].map { |playlist| playlist['id'] }

    @playlist_public = playlist_ids.include?(playlist_id)

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
end
