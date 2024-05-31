class PlaylistsController < ApplicationController
  def select; end

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
end
