class CreatePlaylistArtistsController < ApplicationController
  before_action :ensure_spotify_token_valid, only: %i[create]
  before_action :set_artist_ids, only: %i[create]
  before_action :set_playlist_name, only: %i[create]
  before_action :set_favorite_tracks, only: %i[create]

  def index
    @favorite_artists = FavoriteArtist.where(user: current_user)
    @artist_ids = @favorite_artists.map { |fa| fa.artist.spotify_id}
  end

  def create
    playlist_name = @playlist_name
    artist_ids = @artist_ids

    # お気に入りに登録した楽曲が10曲以上の場合はランダムで10曲を選択
    favorite_tracks = @favorite_tracks
    target_tracks =[]

    if favorite_tracks.size > 10
      target_tracks = favorite_tracks.sample(10)
    else
      target_tracks = favorite_tracks.cycle.take(10)
    end

    # お気に入り登録済みのアーティストIDとトラックIDを取得
    registered_track = Track.where(id: favorite_tracks).pluck(:spotify_id)
    favorite_artists = FavoriteArtist.where(user: current_user).pluck(:artist_id)
    registered_artist = Artist.where(id: favorite_artists).pluck(:spotify_id)

    # プレイリストに追加する曲を格納
    add_tracks = []

    # おすすめ曲を取得
    target_tracks.each_with_index do |target_track, index|
      track = Track.find_by(id: target_track)

      recommendations = RSpotify::Recommendations.generate(
          limit: 20,
          market: 'JP',
          seed_artists: artist_ids,
          min_tempo: track.tempo - 5,
          max_tempo: track.tempo + 5,
          max_energy: track.energy + 0.04,
          min_energy: track.energy - 0.04,
          target_key: track.key
      )

      recommendations_tracks = recommendations.tracks.shuffle
      recommended_track = recommendations_tracks.find do |rec_track|
        if !registered_track.include?(rec_track.id) && !registered_artist.include?(rec_track.artists.first.id) && !add_tracks.include?(rec_track)
          add_tracks << rec_track.id
        end
        break if add_tracks.size >= index+1
      end
    end

    # ユーザーのspotifyIDを取得
    headers = {
      Authorization: "Bearer #{session[:spotify_access_token]}"
    }
  
    user_response = RestClient.get("https://api.spotify.com/v1/me",headers)
    user_data = JSON.parse(user_response.body)
    user_id = user_data['id']

    # 新規プレイリストの作成
    playlist_response = RestClient.post(
      "https://api.spotify.com/v1/users/#{user_id}/playlists",
      {
        name: playlist_name,
        description: 'New playlist description',
        public: false
      }.to_json,
      {
        Authorization: "Bearer #{session[:spotify_access_token]}",
        content_type: :json,
        accept: :json
      } 
    )
    
    # プレイリストID,URLの取得
    playlist_data = JSON.parse(playlist_response.body)
    playlist_id = playlist_data['id']

    # プレイリストに楽曲を追加
    RestClient.post(
      "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks",
      {
        uris: add_tracks.map {|track_id| "spotify:track:#{track_id}"}
      }.to_json,
      {
        Authorization: "Bearer #{session[:spotify_access_token]}",
        content_type: :json
      }
    )

    new_playlist = Playlist.new(user: current_user, name: playlist_name, spotify_id: playlist_id, date: Date.today )

    if new_playlist.save
      flash[:success] = 'プレイリストを作成しました'
      redirect_to playlist_path(new_playlist)
    else
      flash[:danger] = 'プレイリストの作成に失敗しました'
      render 'index'
    end
  end

  private

  def artist_params
    params.require(:create_artist).permit(:playlist_name, artist_ids: [])
  end

  def set_artist_ids
    artist_ids = artist_params[:artist_ids]
    if artist_ids.blank?
      flash[:warning] = "アーティストを選択してください"
      redirect_to create_playlist_artists_path
    else
      @artist_ids = artist_params[:artist_ids].reject(&:blank?)
    end
  end

  def set_playlist_name
    playlist_name = artist_params[:playlist_name]
    if playlist_name.blank?
      @playlist_name = 'New Playlist'
    else
      @playlist_name = playlist_name
    end
  end

  def set_favorite_tracks
    favorite_tracks = favorite_tracks = FavoriteTrack.where(user: current_user).pluck(:track_id)
    if favorite_tracks.blank?
      flash[:warning] = "お気に入り楽曲を登録してください"
      redirect_to favorite_tracks_path
    else
      @favorite_tracks = favorite_tracks
    end
  end
  
end