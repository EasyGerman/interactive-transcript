class AddPodcasts < ActiveRecord::Migration[6.0]
  def change
    create_table :podcasts do |t|
      t.string :code, size: 30, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :lang, size: 5, null: false
      t.string :host, null: false
      t.string :feed_url, null: false
      t.json :settings, null: false, default: {}
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        podcast = ::Podcast.create!(
          code: 'easygerman',
          name: 'The Easy German Podcast',
          lang: 'de',
          host: 'play.easygerman.fm',
          feed_url: ENV.fetch('PODCAST_URL'),
          settings: {
            vocab_helper: {
              enabled: true,
              aws_bucket: "easygermanpodcastplayer-public",
              aws_region: "eu-central-1",
              aws_path: "vocab",
            },
            editor_transcript: {
              dropbox_access_key: ENV.fetch('DROPBOX_ACCESS_KEY'),
              dropbox_shared_link: ENV.fetch('DROPBOX_SHARED_LINK'),
            },
          }
        )

        add_reference :episode_records, :podcast, foreign_key: true, null: false, default: podcast.id
        change_column_default :episode_records, :podcast_id, nil

        add_reference :translation_caches, :podcast, foreign_key: true, null: false, default: podcast.id
        change_column_default :episode_records, :podcast_id, nil
      end

      dir.down do
        remove_column :episode_records, :podcast_id
        remove_column :translation_caches, :podcast_id
      end

      remove_index :episode_records, :access_key
      add_index :episode_records, [:podcast_id, :access_key], unique: true

      remove_index :translation_caches, :key
      add_index :translation_caches, [:podcast_id, :key], unique: true
    end
  end
end
