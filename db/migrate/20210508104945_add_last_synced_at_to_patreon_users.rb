class AddLastSyncedAtToPatreonUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :patreon_users, :last_synced_at, :datetime
  end
end
