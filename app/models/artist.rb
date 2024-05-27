class Artist < ApplicationRecord
  has_many :favorite_artists
  has_many :tracks

  validates :name, presence: true
  validates :spotify_id, presence: true
end
