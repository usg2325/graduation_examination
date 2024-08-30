class CreatePlaylistGenresController < ApplicationController
  before_action :ensure_spotify_token_valid, only: %i[create]
  before_action :set_genres, only: %i[create]
  before_action :set_playlist_name, only: %i[create]
  before_action :set_favorite_tracks, only: %i[create]
  before_action :set_playlist_track_of_number, only: %i[create]

  def index
    @genres = Genre.all
    @favorite_tracks = FavoriteTrack.where(user: current_user)
  end

  def create
    playlist_name = @playlist_name
    playlist_number = @playlist_number

    # 選択されたジャンルの名前を取得
    select_genres = @select_genres

    # お気に入りに登録した楽曲がプレイリストの曲数以上の場合は、ランダムで選択
    favorite_tracks = @favorite_tracks
    target_tracks =[]

    if favorite_tracks.size > 10
      target_tracks = favorite_tracks.sample(10)
    else
      target_tracks = favorite_tracks
    end

    # お気に入り登録済みのアーティストIDとトラックIDを取得
    registered_track = Track.where(id: favorite_tracks).pluck(:spotify_id)
    favorite_artists = FavoriteArtist.where(user: current_user).pluck(:artist_id)
    registered_artist = Artist.where(id: favorite_artists).pluck(:spotify_id)

    # おすすめ曲を格納
    recommendation_tracks = []

    # おすすめ曲を取得
    target_tracks.each do |target_track|
      track = Track.find_by(id: target_track)

      recommendations = RSpotify::Recommendations.generate(
          limit: 20,
          market: 'JP',
          seed_genres: select_genres,
          min_tempo: track.tempo - 5,
          max_tempo: track.tempo + 5,
          max_energy: track.energy + 0.04,
          min_energy: track.energy - 0.04,
          target_key: track.key
      )
      recommendation_tracks.concat(recommendations.tracks)
    end

    # プレイリストに追加する曲を格納
    add_tracks = []

    # プレイリストに追加する曲を選択
    recommendation_tracks = recommendation_tracks.shuffle
    recommended_track = recommendation_tracks.find do |rec_track|
      if !registered_track.include?(rec_track.id) && !registered_artist.include?(rec_track.artists.first.id) && !add_tracks.include?(rec_track.id)
        add_tracks << rec_track.id
      end
      break if add_tracks.size >= playlist_number
    end

    if add_tracks.size < playlist_number
      add_recommendation
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
      flash[:error] = 'プレイリストの作成に失敗しました'
      render 'index'
    end
  end

  private

  def genre_params
    params.require(:create_genre).permit(:playlist_name, :playlist_number, genre_ids: [])
  end

  def set_genres
    genre_ids = genre_params[:genre_ids]
    if genre_ids.blank?
      flash[:warning] = "ジャンルを選択してください"
      redirect_to create_playlist_genres_path
    else
      genre_ids = genre_params[:genre_ids].reject(&:blank?)
      # 選択されたジャンルの名前を取得
      @select_genres = Genre.where(id: genre_ids).pluck(:name)
    end 
  end

  def set_playlist_name
    playlist_name = genre_params[:playlist_name]
    if playlist_name.blank?
      @playlist_name = 'New Playlist'
    else
      @playlist_name = playlist_name
    end
  end

  def set_favorite_tracks
    favorite_tracks = FavoriteTrack.where(user: current_user).pluck(:track_id)
    favorite_tracks_count = favorite_tracks.length
    if favorite_tracks_count < 5
      flash[:warning] = "お気に入り楽曲を5曲以上登録してください"
      redirect_to favorite_tracks_path
    else
      @favorite_tracks = favorite_tracks
    end
  end

  def set_playlist_track_of_number
    playlist_number_str = genre_params[:playlist_number]

    if playlist_number_str.blank?
      @playlist_number = 10
      return
    end

    playlist_number = playlist_number_str.tr('０-９', '0-9').to_i

    if playlist_number >= 10 && playlist_number <= 30
      @playlist_number = playlist_number
    elsif playlist_number < 10 || playlist_number > 30
      flash[:warning] = "10から30曲の間で設定してください"
      redirect_to create_playlist_genres_path
    end
  end

  def add_recommendation
    target_tracks = favorite_tracks.sample(3)
    # おすすめ曲を格納
    recommendation_tracks = []

    # おすすめ曲を取得
    target_tracks.each do |target_track|
      track = Track.find_by(id: target_track)

      recommendations = RSpotify::Recommendations.generate(
          limit: 30,
          market: 'JP',
          seed_genres: select_genres,
          min_tempo: track.tempo - 7,
          max_tempo: track.tempo + 7,
          max_energy: track.energy + 0.08,
          min_energy: track.energy - 0.08,
          target_key: track.key
      )
      recommendation_tracks.concat(recommendations.tracks)
    end

    # プレイリストに追加する曲を選択
    recommendation_tracks = recommendation_tracks.shuffle
    recommended_track = recommendation_tracks.find do |rec_track|
      if !registered_track.include?(rec_track.id) && !registered_artist.include?(rec_track.artists.first.id) && !add_tracks.include?(rec_track.id)
        add_tracks << rec_track.id
      end
      break if add_tracks.size >= playlist_number
    end
  end

end
