class Episode
  extend Memoist

  attr_reader :node

  def initialize(node)
    @node = node
  end

  def title
    node.css('title').first.text
  end

  def html
    node.css('description').text
  end

  def access_key
    if html =~ %r{egp(\w+)_transkript(_(\w{12,}))?.html}
      code, _, secret = $1, $2, $3
      secret || code
    end
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

  def paragraphs
    Nokogiri::HTML(html_with_timestamps_tagged).css('p').to_a
      .select { |node|
        # require 'pry'; binding.pry
        node.css('.timestamp').length > 0
      }
      .map { |node| Paragraph.new(node) }
  end
end
