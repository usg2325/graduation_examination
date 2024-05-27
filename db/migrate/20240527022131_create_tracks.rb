class CreateTracks < ActiveRecord::Migration[7.1]
  def change
    create_table :tracks do |t|
      t.string :name, null: false
      t.string :spotify_id, null: false
      t.references :artist, null: false, foreign_key: true
      t.float :energy, null: false
      t.integer :key, null: false
      t.float :tempo, null: false

      t.timestamps
    end
  end
end
