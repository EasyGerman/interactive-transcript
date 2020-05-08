class CreateEpisodeRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :episode_records do |t|
      t.string :access_key, index: true
      t.string :slug, index: true
      t.text :transcript

      t.timestamps
    end
  end
end
