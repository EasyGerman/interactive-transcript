class CreatePatreonUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :patreon_users do |t|
      t.string :patreon_user_id, null: false, unique: true
      t.json :oauth_data
      t.json :user_data

      t.timestamps
    end
  end
end
