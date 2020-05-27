class Paragraph
  extend Memoist

  attr_reader :node, :timestamp, :label, :text, :segments, :chapter, :index

  delegate :episode_description, to: :chapter
  delegate :episode, to: :episode_description

  def initialize(node, chapter, index)
    @node = node
    @chapter = chapter
    @index = index
    ts = node.text[Timestamp::REGEX] or raise "Could not find timestamp in #{node.text}"
    @timestamp = Timestamp.new(ts[1..-2])
    @label, @text = node.text.split(ts).map(&:strip)
  end

  def slug
    Digest::SHA1.hexdigest("#{timestamp.to_seconds} #{text}")
  end

  def sentences
    text.split(%r{(?<=[\.?!…] )})
  end

  def speaker
    Speaker.new(label.sub(':', ''))
  end

  def match?(other)
    timestamp.to_s == other.timestamp.to_s &&
      Levenshtein.normalized_distance(text, other.text) < 0.3
  end

  memoize def signature
    Digest::SHA1.hexdigest("#{timestamp}-#{text}")[0..7]
  end

  memoize def segments
    Bench.m('Paragraph.segments') do
      if timed_paragraph && text == timed_paragraph.text
        timed_paragraph.segments
      end
    end
  end

  def next_paragraph_in_chapter
    chapter.paragraphs[index + 1]
  end

  memoize def next_paragraph
    next_paragraph_in_chapter || chapter.next_chapter&.paragraphs.first
  end

  def end_timestamp
    if next_paragraph_in_chapter
      next_paragraph_in_chapter.timestamp
    else
      chapter.end_timestamp
    end
  end

  def duration
    end_timestamp - timestamp
  end

  memoize def timed_paragraph
    return if episode.timed_script.nil?
    Bench.m("#{self.class.name}##{__method__}") do
      episode.timed_script.paragraphs.find { |tp| match?(tp) }
    end
  end

  memoize def translation_id
    TranslationCache.add_original_nx(text).key
  end

  Speaker = Struct.new(:name)
end
