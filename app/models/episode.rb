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
    Timestamp.tag_in_html(html)
  end

  def audio_url
    node.css('enclosure').first["url"]
  end
end
