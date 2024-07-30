class ChangeIdToUuidPlaylists < ActiveRecord::Migration[7.1]
  def up
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    add_column :playlists, :uuid, :uuid, default: 'gen_random_uuid()', null: false

    remove_column :playlists, :id

    rename_column :playlists, :uuid, :id

    execute 'ALTER TABLE playlists ADD PRIMARY KEY (id);'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
