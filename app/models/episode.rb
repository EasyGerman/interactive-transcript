class Episode
  extend Memoist

  attr_reader :node

  def initialize(node)
    @node = node
  end

  def slug
    url = node.css('link').text
    url[%r{^https://www.patreon.com/posts/(.*)$}, 1] || raise("Cannot find slug in #{url}")
  end

  def title
    node.css('title').first.text
  end

  def description_html
    node.css('description').text
  end

  memoize def description
    EpisodeDescription.new(description_html, self)
  end

  delegate :notes_html, :chapters, :processed_html, :pretty_html, :access_key, :vocab_url, :vocab, to: :description

  memoize def record
    EpisodeRecord.find_by(access_key: access_key) || EpisodeRecord.find_by(slug: slug)
  end

  memoize def transcript_editor_html
    if Rails.env.development?
      episode_path = Rails.root.join("data", "episodes", slug)
      path = episode_path.join("transcript_editor.html")
      File.read(path) if File.exists?(path)
    else
      return if record.blank?
      doc = Nokogiri::HTML(record.transcript)
      transcript_html = doc.css('#transcript').to_html
    end
  end

  def transcript
    Transcript.new(transcript_editor_html) if transcript_editor_html.present?
  end

  memoize def timed_script
    TimedScript.new(transcript_editor_html) if transcript_editor_html
  end

  def audio_url
    node.css('enclosure').first["url"]
  end

  memoize def audio
    Audio.new(audio_url)
  end

  def paragraphs
    chapters.flat_map(&:paragraphs)
  end
end
