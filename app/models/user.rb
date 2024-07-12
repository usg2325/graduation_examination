class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :favorite_artists, dependent: :destroy
  has_many :favorite_tracks, dependent: :destroy
  has_many :playlists, dependent: :destroy

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true, length: { maximum: 255 }

  validates :reset_password_token, uniqueness: true, allow_nil: true
end
