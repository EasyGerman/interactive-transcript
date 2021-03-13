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
    ContentProvider.import_podcasts_from_files
  end
end
