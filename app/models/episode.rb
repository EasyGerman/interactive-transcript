class Episode
  extend Memoist
  include ErrorHandling

  attr_reader :node, :feed

  def initialize(fetcher, node, feed)
    @fetcher = fetcher
    @node = node
    @feed = feed
    @feed_entry_parser = Feed::EntryParser.new(node)
  end

  def number
    feed_entry_parser.episode_number
  end

  delegate :slug, :title, :audio_url, :published_at, to: :feed_entry_parser
  delegate :access_key, :vocab_url, :downloadable_html_url, :notes_html, to: :feed_entry_description_parser
  delegate :chapters, to: :transcript

  memoize def transcript
    if published_at >= Date.parse("2020-10-13 00:00 UTC") && downloadable_html_url.present?
      ::TranscriptFromFile.new(downloadable_html, self)
    else
      ::TranscriptFromFeed.new(feed_entry_description_parser, self)
    end
  rescue Feed::EntryDescriptionParser::TranscriptHeaderNotFound
    if downloadable_html_url.present?
      ::TranscriptFromFile.new(downloadable_html, self)
    end
  end

  memoize def downloadable_html
    return @fetcher.fetch_downloadable_transcript(self) if @fetcher.present?

    # TODO: move to fetcher
    URI.open(downloadable_html_url).read
  end

  memoize def transcript_editor_html
    return @fetcher.fetch_editor_transcript(self) if @fetcher.present?

    # TODO: move to fetcher
    if Rails.env.development?
      episode_path = Rails.root.join("data", "episodes", slug)
      path = episode_path.join("transcript_editor.html")
      return File.read(path) if File.exists?(path)
    end

    hide_and_report_errors do
      file_contents = DropboxAdapter.new.transcript_for(number)
      doc = Nokogiri::HTML(file_contents)
      doc.css('#transcript').to_html
    end
  end

  memoize def timed_script
    hide_and_report_errors do
      TimedScript.new(transcript_editor_html) if transcript_editor_html
    end
  end

  memoize def audio
    Audio.new(audio_url)
  end

  # Vocab - for experimental use
  memoize def vocab
    Vocab.new(vocab_url) if vocab_url.present?
  end

  memoize def processed
    ::Processed::Episode.new(
      title: title,
      cover_url: feed.cover_url,
      audio_url: audio_url,
      notes_html: notes_html,
      chapters: chapters&.map(&:processed),
      audio_chapters: processed_audio_chapters,
    )
  end

  def processed_audio_chapters
    return nil if chapters.nil? # No transcript, e.g. Zwischending

    audio.chapters.to_enum.with_index.map { |chapter, index|
      if chapter.picture.present?
        Rails.logger.info "Scheduling job #{chapter.id}"

        Concurrent::ScheduledTask.execute(2 + index) do
          upload_to_aws("vocab/#{access_key}/#{chapter.id}.jpg", chapter.picture.data)
        end
      end
      ::Processed::AudioChapter.new(
        id: chapter.id,
        start_time: chapter.start_time / 1000,
        end_time: chapter.end_time / 1000,
        has_picture: chapter.picture.present?,
      )
    }
  end

  def upload_to_aws(path, data)
    Rails.logger.info "Uploading #{path} (#{data.size} bytes)"
    file = Tempfile.new(encoding: 'ascii-8bit')
    begin
      file.write(data)
      file.rewind

      object = Aws::S3::Resource.new(region: 'eu-central-1').bucket('easygermanpodcastplayer-public').object(path)
      object.upload_file(file.path)

      Rails.logger.info "Finished uploading #{path}"
    rescue => e
      Rails.logger.error "Failed uploading #{path}: #{e.class.name} #{e.message} #{e.backtrace.first}"
    ensure
      file.close
      file.unlink
    end
  end

  private

  attr_reader :feed_entry_parser, :feed_entry_description_parser

  memoize def feed_entry_description_parser
    Feed::EntryDescriptionParser.new(feed_entry_parser.description, self)
  end

end
