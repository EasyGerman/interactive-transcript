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

  attr_reader :node, :feed, :podcast, :fetcher
  attr_reader :feed_entry_parser, :feed_entry_description_parser

  def initialize(podcast, fetcher, node, feed)
    @podcast = podcast
    @fetcher = fetcher.for_episode(self)
    @node = node
    @feed = feed
    @feed_entry_parser = Feed::EntryParser.new(podcast, feed, node)
  end

  def number
    feed_entry_parser.episode_number || (0 if slug == 'trailer') # TODO
  end

  delegate :slug, :title, :audio_url, :published_at, :episode_number, to: :feed_entry_parser
  delegate :vocab_url, :downloadable_html_url, :notes_html, :pretty_html, to: :feed_entry_description_parser
  delegate :chapters, to: :transcript, allow_nil: true

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
    fetcher.fetch_downloadable_transcript
  end

  memoize def transcript_editor_html
    hide_and_report_errors do
      doc = Nokogiri::HTML(transcript_editor_contents)
      doc.css('#transcript').to_html
    end
  end

  memoize def transcript_editor_contents
    fetcher.fetch_editor_transcript
  end

  # Used by Paragraph to find matching timed paragraph
  memoize def timed_script
    hide_and_report_errors do
      TimedScript.new(transcript_editor_html) if transcript_editor_html
    end
  end

  memoize def timed_script2
    hide_and_report_errors do
      TimedScript2.new(transcript_editor_html) if transcript_editor_html
    end
  end

  memoize def audio
    Audio.new(fetcher)
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

  memoize def identifiers
    EpisodeIdentifiers.new(
      entry_link_url: feed_entry_parser.link_url,
      transcript_player_url: feed_entry_description_parser.transcript_player_url,
      downloadable_html_url: feed_entry_description_parser.downloadable_html_url,
    )
  end

  memoize def short_name
    identifiers.short_name
  end

  memoize def access_key
    identifiers.access_key
  end
end
