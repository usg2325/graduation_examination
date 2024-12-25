class CreateFavoriteArtists < ActiveRecord::Migration[7.1]
  def change
    create_table :favorite_artists do |t|
      t.references :user, foreign_key: true
      t.references :artist, foreign_key: true

      t.timestamps
    end
  end
end
