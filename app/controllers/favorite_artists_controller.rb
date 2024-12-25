class FavoriteArtistsController < ApplicationController
  before_action :set_favorite_artist, only: %i[destroy]

  def index
    @favorite_artists = FavoriteArtist.where(user: current_user)
    @artist_ids = @favorite_artists.map { |fa| fa.artist.spotify_id }
  end

  def new; end

  def create
    artist_params = favorite_artist_params
    artist_id = artist_params[:artist_id]
    artist_name = artist_params[:artist_name]

    if Artist.exists?(spotify_id: artist_id)
      @artist = Artist.find_by(spotify_id: artist_id)
    else
      @artist = Artist.new(name: artist_name, spotify_id: artist_id)
      unless @artist.save
        flash[:danger] = "アーティストの登録に失敗しました"
        render 'new'
        return
      end
    end

    if FavoriteArtist.exists?(user: current_user, artist: @artist)
      flash[:alert] = 'すでにお気に入りに登録済みです'
      redirect_to favorite_artists_path
      return
    end

    @favorite_artist = FavoriteArtist.new(user: current_user, artist: @artist)

    if @favorite_artist.save
      flash[:success] = 'お気に入りに追加しました'
      redirect_to favorite_artists_path
    else
      flash[:danger] = 'お気に入りの登録に失敗しました'
      render 'new'
    end
  end

  def search
    artist_name = params[:artist_name]

    if artist_name.present?
      query = "artist:\"#{params[:artist_name]}*\""
    end

    if query.present?
      @artists = RSpotify::Artist.search(query, market:'JP', limit:20)
      if @artists.present?
        @top_tracks = {}
        @artists.each do |artist|
          artist_id = artist.id
          @top_tracks[artist_id] = RSpotify::Artist.find(artist_id).top_tracks('JP').first
        end
      else
        flash.now[:alert] = '該当するアーティストが見つかりませんでした'
      end
    else
      flash.now[:warning] = 'アーティスト名を入力してください'
    end
    render 'new'
  end

  def destroy
    @favorite_artist.destroy!
    flash[:success] = "お気に入りから削除しました"
    redirect_to favorite_artists_path, status: :see_other
  end

  private

  def favorite_artist_params
    params.require(:favorite_artist).permit(:artist_name, :artist_id)
  end

  def set_favorite_artist
    @favorite_artist = FavoriteArtist.find(params[:id])
  end    
end
