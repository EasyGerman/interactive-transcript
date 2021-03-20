namespace :episodes do
  desc 'Fill short_name in the database'
  task :fill_short_name => :environment do
    Util.log_to_stdout
    Podcast.all.each do |podcast|
      puts "Podcast: #{podcast.name}"
      feed = Feed.new(podcast)
      feed.episodes.each do |episode|
        puts "Episode: #{episode.title}"
        puts "Access key: #{episode.access_key}"
        next if episode.access_key.blank?

        episode_record = podcast.episode_records.find_by(access_key: episode.access_key)
        if episode_record.blank?
          puts "Episode not found by access_key"
          next
        end

        puts "Episode number: #{episode.number}"
        episode_record.update!(short_name: episode.number)
      end
    end
  end

  desc 'Check that short name is compatible with the stored version'
  task :check_short_name => :environment do
    Util.log_to_stdout
    Podcast.all.each do |podcast|
      feed = Feed.new(podcast)
      feed.episodes.each do |episode|
        next if episode.access_key.blank?

        episode_record = podcast.episode_records.find_by(access_key: episode.access_key)
        next if episode_record.blank?

        unless episode.short_name == episode_record.short_name
          puts "#{podcast.code}  #{episode.access_key}  existing: #{episode_record.short_name}  #{episode.short_name == episode_record.short_name ? 'OK' : "WRONG - new: #{episode.short_name}"}"
        end
      end
    end
  end

  desc 'Check that access_key is compatible with the stored version'
  task :check_access_key => :environment do
    Util.log_to_stdout
    Podcast.all.each do |podcast|
      feed = Feed.new(podcast)
      feed.episodes.each do |episode|
        next if episode.access_key.blank?

        episode_record = podcast.episode_records.find_by(access_key: episode.access_key)
        next if episode_record.blank?

        # unless episode.access_key == episode_record.access_key
          puts "#{podcast.code}  #{episode.access_key}  existing: #{episode_record.access_key}  #{episode.access_key == episode_record.access_key ? 'OK' : "WRONG - new: #{episode.access_key}"}"
        # end
      end
    end
  end
end
