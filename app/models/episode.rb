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
    html.gsub(%r{\[((\d{1,2}:)?\d{1,2}:\d{2})\]}) do |m|
      sec = $1.split(":").reverse.to_enum.with_index.map { |x, i| x.to_i * (60 ** i) }.sum
      "<span class='timestamp' data-timestamp='#{sec}'>[#{$1}]</span>"
    end.html_safe
  end

  def audio_url
    node.css('enclosure').first["url"]
  end
end
