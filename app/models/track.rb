class Track < ApplicationRecord
  has_many :favorite_tracks
  belongs_to :artist

  validates :name, presence: true
  validates :spotify_id, presence: true
  validates :artist, presence: true
  validates :energy, presence: true
  validates :key, presence: true
  validates :tempo, presence: true
end
