#
# Transcript that contains a timestamp for individial words.
#
class TimedScript2
  extend Memoist

  attr_reader :html

  def initialize(html)
    @html = html
  end

  memoize def doc
    Nokogiri::HTML(html)
  end

  def inner_node
    doc.css('#transcript')
  end

  memoize def parsed_paragraphs
    TimedScript2::Parser.new(doc).paragraphs
  end

  memoize def paragraphs
    parsed_paragraphs.map do |parsed_paragraph|
      process_paragraph(parsed_paragraph)
    end
  end

  def process_paragraph(parsed_paragraph)
    TimedScript2::Processor.new(parsed_paragraph: parsed_paragraph).call
  end

  def as_plain_text
    paragraphs.map(&:segments_as_plain_text).join("\n\n")
  end

end
