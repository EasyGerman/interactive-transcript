class AlterEpisodeRecords < ActiveRecord::Migration[6.0]
  def change
    remove_column :episode_records, :slug, :string, index: true
    remove_column :episode_records, :transcript, :string

    change_column_null :episode_records, :access_key, false

    remove_index :episode_records, :access_key
    add_index :episode_records, :access_key, unique: true

    add_column :episode_records, :data, :json
  end
end
