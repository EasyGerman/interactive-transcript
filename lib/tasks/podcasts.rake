namespace :podcasts do
  desc 'Export podcasts from the database to file'
  task :dump => :environment do
    Util.log_to_stdout
    Podcast.all.each do |podcast|
      config = podcast.attributes.except('id', 'created_at', 'updated_at')
      ContentProvider.for_podcast(podcast).write_config(config)
    end
  end

  desc 'Import podcasts from the files to database'
  task :load => :environment do
    Util.log_to_stdout
    ContentProvider.each_podcast do |podcast_storage|
      config = podcast_storage.read_config
      begin
        podcast = Podcast.create!(config)
        Rails.logger.info 'Podcast #{podcast.code} imported'
      rescue ActiveRecord::RecordNotUnique
        podcast = Podcast.find_by!(code: config.fetch('code'))
        podcast.attributes = config
        if podcast.changed?
          podcast.save!
          Rails.logger.info 'Podcast #{podcast.code} updated'
        else
          Rails.logger.info 'Podcast #{podcast.code} unchanged'
        end
      end
    end
  end
end
