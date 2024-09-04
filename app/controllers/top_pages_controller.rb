class TopPagesController < ApplicationController
  skip_before_action :require_login, only:%i[top]

  def top; end

  def app_top
    @favorite_tracks = FavoriteTrack.where(user: current_user)
  end
end
