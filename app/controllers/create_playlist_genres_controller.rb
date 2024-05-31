class CreatePlaylistGenresController < ApplicationController
  before_action :ensure_spotify_token_valid, only: %i[create]

  def index
    @genres = Genre.all
  end

  def create
    new_playlist_name = params[:playlist_name]
    if new_playlist_name == nil
      playlist_name = 'New Playlist'
    else
      playlist_name = new_playlist_name
    end

    genre_ids = params[:genre_ids].reject(&:blank?)
    # 選択されたジャンルの名前を取得
    select_genres = Genre.where(id: genre_ids).pluck(:name)

    # お気に入りに登録した楽曲が15曲以上の場合はランダムで15曲を選択
    favorite_tracks = FavoriteTrack.where(user: current_user).pluck(:track_id)
    target_tracks =[]

    if favorite_tracks.size > 15
      target_tracks = favorite_tracks.sample(15)
    else
      target_tracks = favorite_tracks
    end

    # 選択した楽曲のtempo,energyの平均値とkeyの最頻値をランダムで1つ取得
    target_tempo = []
    target_energy = []
    target_key = []

    target_tracks.each do |target_track|
      track = Track.find_by(id: target_track)
      target_tempo << track.tempo
      target_energy << track.energy
      target_key << track.key
    end

    @tempo = average(target_tempo)
    @energy = average(target_energy)
    @key = mode(target_key)

    # お気に入り登録済みのアーティストIDとトラックIDを取得
    registered_track = Track.where(id: favorite_tracks).pluck(:spotify_id)
    favorite_artists = FavoriteArtist.where(user: current_user).pluck(:artist_id)
    registered_artist = Artist.where(id: favorite_artists).pluck(:spotify_id)

    # おすすめ曲を取得
    recommendations = RSpotify::Recommendations.generate(
        limit: 30,
        market: 'JP',
        seed_genres: select_genres,
        min_tempo: @tempo - 5,
        max_tempo: @tempo + 5,
        max_energy: @energy + 0.04,
        min_energy: @energy - 0.04,
        target_key: @key
    )

    # プレイリストに追加する曲を選択
    add_tracks = []

    recommendations_tracks = recommendations.tracks.shuffle
    recommended_track = recommendations_tracks.find do |rec_track|
      if !registered_track.include?(rec_track.id) && !registered_artist.include?(rec_track.artists.first.id) && !add_tracks.include?(rec_track)
        add_tracks << rec_track.id
      end
      break if add_tracks.size >= 15
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

  # 平均値
  def average(array)
    array.sum.to_f / array.size
  end

  # 最頻値
  def mode(array)
    return nil if array.empty?
    # 各要素の出現回数をカウント
    frequency = array.each_with_object(Hash.new(0)) { |num, hash| hash[num] += 1 }
    # 最も多く出現した回数を取得
    max_frequency = frequency.values.max
    # 最頻値を取得（複数ある場合も含む）
    mode_values = frequency.select { |k, v| v == max_frequency }.keys
    # 複数の最頻値からランダムに1つを選んで返す
    mode_values.sample
  end
end
