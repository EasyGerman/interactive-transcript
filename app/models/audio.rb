require "mp3info"

class Audio
  extend Memoist

  attr_reader :fetcher_for_episode

  def initialize(fetcher_for_episode)
    @fetcher_for_episode = fetcher_for_episode
  end

  memoize def content
    fetcher_for_episode.fetch_audio
  end

  memoize def mp3_parser
    Mp3Parser.new(content)
  end

  memoize def mp3_parser
    Mp3Parser.new(content)
  end

  memoize def chapters
    mp3_parser.chapters
  end

  def end_time
    chapters.last&.end_time || mp3_parser.duration * 1000
  end

  def processed_chapters
    return nil if chapters.nil? # No transcript, e.g. Zwischending

    chapters.to_enum.with_index.map { |chapter, index|
      ::Processed::AudioChapter.new(
        id: chapter.id,
        start_time: chapter.start_time / 1000,
        end_time: chapter.end_time / 1000,
        has_picture: chapter.picture.present?,
      )
    }
  end
end
