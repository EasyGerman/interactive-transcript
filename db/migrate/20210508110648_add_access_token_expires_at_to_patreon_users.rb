class AddAccessTokenExpiresAtToPatreonUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :patreon_users, :access_token_expires_at, :datetime
  end
end
