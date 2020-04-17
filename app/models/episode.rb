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

  memoize def html_node
    Nokogiri::HTML(html)
  end

  def processed_html
    modified_html = Timestamp.tag_in_html(html)

    nokogiri_html = Nokogiri::HTML(modified_html)
    nokogiri_html.css('p').each do |node|
      if node.css('.timestamp').length > 0
        node['class'] = "timestampedEntry"
        node['data-translation-id'] = Digest::SHA1.hexdigest Paragraph.new(node).text
      end
    end
    nokogiri_html.css('body').children.to_html.html_safe
  end

  def audio_url
    node.css('enclosure').first["url"]
  end

  def paragraphs
    Nokogiri::HTML(html).css('p').to_a
      .select { |node| node.css('.timestamp') }
      .map { |node| Paragraph.new(node) }
  end
end
