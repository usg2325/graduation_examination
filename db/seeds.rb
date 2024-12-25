# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Genre .delete_all

genres = ["j-pop", "j-rock", "j-idol", "j-dance", "anime", "k-pop", "edm", "hip-hop", "pop", "rock", "dance", "chill", "classical", "singer-songwriter", "soul", "soundtracks", "r-n-b", "ambient", "indie", "alternative"]

genres.each do |genre|
  Genre.find_or_create_by!(name: genre)
end
