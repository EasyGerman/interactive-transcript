Chapter = Struct.new(:title, :paragraphs, :episode, :index)
Chapter.class_eval do
  extend Memoist

  def timestamp
    paragraphs.first.timestamp
  end

  memoize def end_timestamp
    if next_chapter
      next_chapter.timestamp - 4.seconds
    else
      Timestamp.from_seconds(episode.audio.end_time / 1000)
    end
  end

  def duration
    end_timestamp - timestamp
  end

  def next_chapter
    episode_description.chapters[index + 1]
  end

  def processed
    ::Processed::Chapter.new(
      title: title,
      paragraphs: paragraphs.map(&:processed),
    )
  end

end
