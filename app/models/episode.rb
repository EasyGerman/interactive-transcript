# High-level representation of a podcast episode.
#
# Responsibilities:
#
# - decide how the transcript is processed (TODO: extract)
# -
#
class Episode
  extend Memoist
  include ErrorHandling
  include AwsUtils

  attr_reader :node, :feed, :podcast
  attr_reader :feed_entry_parser, :feed_entry_description_parser

  def initialize(podcast, fetcher, node, feed)
    @podcast = podcast
    @fetcher = fetcher
    @node = node
    @feed = feed
    @feed_entry_parser = Feed::EntryParser.new(podcast, node)
  end

  def number
    feed_entry_parser.episode_number || (0 if slug == 'trailer') # TODO
  end

  delegate :slug, :title, :audio_url, :published_at, to: :feed_entry_parser
  delegate :access_key, :vocab_url, :downloadable_html_url, :notes_html, :pretty_html, to: :feed_entry_description_parser
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
    @fetcher.fetch_downloadable_transcript(self)
  end

  memoize def transcript_editor_html
    hide_and_report_errors do
      doc = Nokogiri::HTML(transcript_editor_contents)
      doc.css('#transcript').to_html
    end
  end

  memoize def transcript_editor_contents
    @fetcher.fetch_editor_transcript(self)
  end

  # Used by Paragraph to find matching timed paragraph
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
      audio_chapters: audio.processed_chapters,
    )
  end

  memoize def feed_entry_description_parser
    Feed::EntryDescriptionParser.new(feed_entry_parser.description, self)
  end
end
