Chapter = Struct.new(:parent, :title, :paragraphs, :episode, :index)
Chapter.class_eval do
  extend Memoist

  def timestamp
    paragraphs.first&.timestamp
  end

  memoize def end_timestamp
    if next_chapter
      return if next_chapter.timestamp.blank?
      next_chapter.timestamp - 4.seconds
    else
      Timestamp.from_seconds(episode.audio.end_time / 1000)
    end
  end

  def duration
    return if timestamp.blank?
    return if end_timestamp.blank?
    end_timestamp - timestamp
  end

  def next_chapter
    parent.chapters[index + 1]
  end

  def processed
    ::Processed::Chapter.new(
      title: title,
      paragraphs: paragraphs.map(&:processed),
    )
  end

end
