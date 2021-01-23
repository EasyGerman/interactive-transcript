#
# Transcript that contains a timestamp for individial words.
#
class TimedScript
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

  memoize def paragraphs
    Bench.m("#{self.class.name}##{__method__}") do
      paras.map do |para|
        Paragraph.new(
          para[:time],
          Speaker.new(*para[:speaker]),
          para[:items], # slices
        )
      end
    end
  end

  # []{ speaker: Tuple<id, name>, time: string, items: Tuple<text, ts, text> }
  def paras
    TimedScript::Iterator.new(doc).paragraphs
  end
end
