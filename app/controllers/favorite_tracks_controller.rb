class FavoriteTracksController < ApplicationController
  before_action :ensure_spotify_token_valid, only: %i[create]
  before_action :set_favorite_track, only: %i[destroy]

  def index
    @favorite_tracks = FavoriteTrack.where(user: current_user).page(params[:page]).per(20)
    @track_ids = @favorite_tracks.map { |fa| fa.track.spotify_id }
  end

  def create
    track_params = favorite_track_params
    track_id = track_params[:track_id]
    track_name = track_params[:track_name]
    artist_name = track_params[:artist_name]

    # 楽曲が選択されていなかった場合、処理を終了
    if track_id.blank?
      return
    end

    if Track.exists?(spotify_id: track_id)
      @track = Track.find_by(spotify_id: track_id)
    else
      # トラックのアーティストIDを取得
      track = RSpotify::Track.find(track_id)
      artist_id = track.artists.first.id
      if Artist.exists?(spotify_id: artist_id)
        @artist = Artist.find_by(spotify_id: artist_id)
      else
        @artist = Artist.new(name: artist_name, spotify_id: artist_id)
      end
      # 分析情報を取得
      headers = {
        Authorization: "Bearer #{session[:spotify_access_token]}"
      }
      response = RestClient.get("https://api.spotify.com/v1/audio-features/#{track_id}", headers)
      data = JSON.parse(response.body)

      energy = data['energy']
      key = data['key']
      tempo = data['tempo']

      @track = Track.new(name: track_name, spotify_id: track_id, artist: @artist, energy: energy, key: key, tempo: tempo)
      unless @track.save
        flash[:error] = "楽曲の登録に失敗しました"
        render 'new'
        return
      end
    end

    if FavoriteTrack.exists?(user: current_user, track: @track)
      flash[:alert] = "すでにお気に入りに登録済みです"
      redirect_to favorite_tracks_path
    else
      @favorite_track = FavoriteTrack.new(user: current_user, track: @track)
      if @favorite_track.save
        flash[:success] = 'お気に入りに追加しました'
        redirect_to favorite_tracks_path
      else
        flash[:error] = 'お気に入りの登録に失敗しました'
        render 'new'
      end
    end
  end

  def new; end

  def search
    track_name = params[:track_name]
    artist_name = params[:artist_name]
    
    if artist_name.present? && track_name.present?
      query = "track:\"#{track_name}*\" artist:\"#{artist_name}\""
    elsif track_name.present?
      query = "track:\"#{track_name}*\""
    elsif artist_name.present?
      query = "artist:\"#{artist_name}\""
    end

    if query.present?
      @tracks = RSpotify::Track.search(query, market:'JP', limit:50)
      if @tracks.blank?
        flash.now[:alert] = '該当する楽曲が見つかりませんでした'
      end
    else
      flash.now[:warning] = '楽曲名またはアーティスト名を入力してください'
    end
    render 'new'
  end

  def destroy
    @favorite_track.destroy!
    flash[:success] = 'お気に入りから削除しました'
    redirect_to favorite_tracks_path, status: :see_other
  end

  private

  def favorite_track_params
    params.require(:favorite_track).permit(:track_id, :track_name, :artist_name)
  end

  def set_favorite_track
    @favorite_track = FavoriteTrack.find(params[:id])
  end
end
