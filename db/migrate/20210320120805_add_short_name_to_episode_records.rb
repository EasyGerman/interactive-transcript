class AddShortNameToEpisodeRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :episode_records, :short_name, :string
  end
end
