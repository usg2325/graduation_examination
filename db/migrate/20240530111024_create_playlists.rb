class CreatePlaylists < ActiveRecord::Migration[7.1]
  def change
    create_table :playlists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :spotify_id, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
