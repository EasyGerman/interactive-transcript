require "mp3info"

class Audio
  extend Memoist

  attr_reader :url

  def initialize(url)
    @url = url
  end

  memoize def content
    CachedNetwork.fetch(url)
  end

  memoize def chapters
    Mp3Parser.new(content).chapters
  end

  def end_time
    chapters.last.end_time
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
