class CreateFavoriteTracks < ActiveRecord::Migration[7.1]
  def change
    create_table :favorite_tracks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true

      t.timestamps
    end
  end
end
