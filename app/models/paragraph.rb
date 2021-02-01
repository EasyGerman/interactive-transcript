class Paragraph
  extend Memoist
  include ErrorHandling

  attr_reader :node, :timestamp, :label, :text, :segments, :chapter, :index

  delegate :episode, to: :chapter

  def initialize(node, chapter, index)
    @node = node
    node_text = node.is_a?(String) ? node : node.text
    @chapter = chapter
    @index = index
    @timestamp_string = node_text[%r{\[[\d:]+\]}]
    if @timestamp_string
      if ts = @timestamp_string[Timestamp::REGEX]
        @timestamp = Timestamp.new(ts[1..-2])
      end
      @label, @text = node_text.split(@timestamp_string, 2).map(&:strip)
      # Replace multiple consecutive spaces with one
      @text.gsub!(/ +/, ' ')
    else
      @text = node_text
    end
  end

  def slug
    Digest::SHA1.hexdigest("#{timestamp&.to_seconds} #{text}")
  end

  def sentences
    text.split(%r{(?<=[\.?!…] )})
  end

  def speaker
    return if label.blank?
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
    hide_and_report_errors do
      Bench.m("#{self.class.name}##{__method__}") do
        episode.timed_script.paragraphs.find { |tp| match?(tp) }
      end
    end
  end

  memoize def translation_id
    TranslationCache.add_original_nx(episode.podcast.id, text).key
  end

  Speaker = Struct.new(:name)

  def processed
    ::Processed::Paragraph.new(
      translation_id: translation_id,
      slug: slug,
      speaker: (::Processed::Speaker.new(name: speaker.name) if speaker),
      timestamp: timestamp&.processed,
      segments: segments&.map(&:processed),
      text: text,
    )
  end
end
