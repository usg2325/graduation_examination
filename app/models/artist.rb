class Artist < ApplicationRecord
  has_many :favorite_artists

  validates :name, presence: true
  validates :spotify_id, presence: true
end
