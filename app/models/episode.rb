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

  def html
    node.css('description').text
  end

  memoize def record
    EpisodeRecord.find_by(access_key: access_key) || EpisodeRecord.find_by(slug: slug)
  end

  memoize def transcript_editor_html
    return if record.blank?
    doc = Nokogiri::HTML(record.transcript)
    html = doc.css('#transcript').to_html

    html.html_safe
  end

  def transcript
    Transcript.new(transcript_editor_html) if transcript_editor_html.present?
  end

  def pretty_html
    html_node.to_html(indent: 2, indent_text: ' ')
  end

  def access_key
    if html =~ %r{egp(\w+)_transkript(_(\w{12,}))?.html}
      code, _, secret = $1, $2, $3
      secret || code
    end
  end

  def vocab_url
    if html =~ %r{https://www.easygerman.org/s/(\w+)_vokabeln(_(\w+))?.(txt|rtf)}
      Regexp.last_match[0]
    end
  end

  memoize def vocab
    Vocab.new(vocab_url) if vocab_url.present?
  end

  memoize def html_node
    Nokogiri::HTML(html)
  end

  memoize def html_with_timestamps_tagged
    Timestamp.tag_in_html(html)
  end

  def processed_html
    nokogiri_html = Nokogiri::HTML(html_with_timestamps_tagged)
    nokogiri_html.css('p').each do |node|
      if node.css('.timestamp').length > 0
        node['class'] = "timestampedEntry"
        text = Paragraph.new(node).text
        translation_cache = TranslationCache.add_original_nx(text)
        node['data-translation-id'] = translation_cache.key
      end
    end
    nokogiri_html.css('body').children.to_html.html_safe
  end

  def audio_url
    node.css('enclosure').first["url"]
  end

  memoize def audio
    Audio.new(audio_url)
  end

  def paragraphs
    Nokogiri::HTML(html_with_timestamps_tagged).css('p').to_a
      .select { |node|
        node.css('.timestamp').length > 0
      }
      .map { |node| Paragraph.new(node) }
  end

  def sentences
    paragraphs.flat_map(&:sentences)
  end
end
