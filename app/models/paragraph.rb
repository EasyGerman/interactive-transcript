class Paragraph
  extend Memoist

  attr_reader :node

  def initialize(node)
    @node = node
  end

  def label
    label_timestamp_text_trio[0]
  end

  def timestamp
    Timestamp.new(label_timestamp_text_trio[1])
  end

  def text
    label_timestamp_text_trio[2].strip
  end

  private

  memoize def label_timestamp_text_trio
    node.text.split(Timestamp::REGEX)
  end

end
