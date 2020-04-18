class Paragraph
  extend Memoist

  attr_reader :node, :timestamp, :label, :text

  def initialize(node)
    @node = node
    ts = node.text[Timestamp::REGEX] or raise "Could not find timestamp in #{node.text}"
    @timestamp = Timestamp.new(ts[1..-2])
    @label, @text = node.text.split(ts).map(&:strip)
  end
end
