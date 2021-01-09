namespace :feed do
  desc "Get information about the whole feed"
  task :stats => :environment do
    total_para_count = 0
    total_text_length = 0
    Feed.new.episodes.map do |episode|
      total_para_count += (ep_para_count = episode.paragraphs.count)
      total_text_length += (ep_text_length = episode.paragraphs.map(&:text).map(&:length).sum)
      puts(
        [
          ("/episodes/#{episode.access_key}" if episode.access_key).to_s.ljust(28),
          ep_para_count.to_s.rjust(3, ' '),
          ep_text_length.to_s.rjust(7, ' '),
          episode.title,
        ].join(" ")
      )
    end
    puts
    puts "Total timestamped paragraphs: #{total_para_count}"
    puts "Total timestamped characters: #{total_text_length}"
  end

  desc "Create local files for each episode (for easier experimentation)"
  task :import_to_files => :environment do
    podcast = Podcast.find_by!(code: ENV.fetch('PODCAST'))
    feed = Feed.new(podcast)
    write feed.content, to: "podcasts/#{podcast.code}/feed.xml"

    with_retry do
      feed.episodes.map do |episode|
        generate_file(episode, 'description.html') { episode.pretty_html }

        if (vocab = episode.vocab).present?
          generate_file(episode, 'vocab.txt') { vocab.plain_text_content }
          # analize_vocab(episode)
        end

        generate_file(episode, 'processed.json') { JSON.pretty_generate(episode.processed.as_json) }
        generate_file(episode, 'processed.yaml') { YAML.dump(episode.processed.as_json) }

        if episode.transcript.present?
          generate_file(episode, 'downloadable.html', rand * retry_delay) { episode.downloadable_html }
          generate_file(episode, 'editor.html', rand * retry_delay) { episode.transcript_editor_html }
        end
      end
    end

    puts "Written #{@written || 0} files. Already exists: #{@already_exists || 0}"
  end

  task :reprocess_all => :environment do
    ALREADY_PROCESSED = *%w[
    ]

    feed = Feed.new
    feed.episodes.each do |episode|
      puts [
        episode.access_key,
        episode.slug,
      ].join(" ")
      next if episode.access_key.in?(ALREADY_PROCESSED)

      with_retry do
        FetchPreparedEpisode.(
          access_key: episode.access_key,
          force_processing: true
        )
      end
    end
  end

  def write(content, to:)
    path = Rails.root.join('data', *Array(to))
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') { |f| f.write(content) }
  end

  def analize_vocab(episode)
    episode.vocab.entries.each do |entry|
      puts
      puts entry.to_s
      WordMatch.new(entry.de, episode.sentences).matches.each do |text|
        puts "- #{text.green}"
      end
    end
  end

  def generate_file(episode, file_name, delay = 0)
    path = Rails.root.join('data', 'podcasts', episode.podcast.code, 'episodes', episode.slug, file_name)
    if File.exist?(path)
      @already_exists ||= 0
      @already_exists += 1
      return
    end

    STDOUT.puts "- #{file_name}"
    sleep delay
    FileUtils.mkdir_p(File.dirname(path))

    with_retry do
      File.open(path, 'w') { |f| f.write(yield) }
      @written ||= 0
      @written += 1
    end
  end

  def retry_delay
    @retry_delay ||= 5
  end

  def with_retry
    begin
      yield
    rescue => e
      if e.message.include?('Too Many Requests')
        STDOUT.puts "Too Many Requests - Sleeping for #{@retry_delay.seconds}..."
        sleep @retry_delay
        @retry_delay *= 2
        retry
      else
        raise
      end
    end
  end
end
