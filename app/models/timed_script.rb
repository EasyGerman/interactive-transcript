#
# Transcript that contains a timestamp for individial words.
#
class TimedScript
  extend Memoist

  attr_reader :html

  def initialize(html)
    @html = html
  end

  memoize def preprocessed_html
    h = html.dup
    h.gsub!('background-color: white;', '')
    h.gsub!('background-position: initial initial;', '')
    h.gsub!('background-repeat: initial initial;', '')
    h.gsub!(/background(\-color)?: rgba\(\d+, \d+, \d+, 0.\d+\);/, '');
    h.gsub!(/background(\-color)?: rgb\(\d+, \d+, \d+\);/, '');
    h.gsub!(/ style="\s*"/, '')
    h.gsub!('&nbsp;', ' ')
    h.gsub!("\u00A0", ' ')
    h
  end

  memoize def doc
    Nokogiri::HTML(preprocessed_html)
  end

  def inner_node
    doc.css('#transcript')
  end

  memoize def paragraphs
    Bench.m("#{self.class.name}##{__method__}") do
      paragraphs = []

      current_speaker = nil

      inner_node.to_html.split("\n").each do |line|
        case line
        when %r{^<b data-spk="(\d+)" title="">(\w+):</b><br>$}
          speaker_number, speaker_name = $1, $2
          current_speaker = Speaker.new($1, $2)
        when %r{^<small style="opacity: 0.5;">\[([\d:]+)\]</small>\s*(.*)$}
          timestamp, rest = $1, $2
          paragraphs << paragraph = Paragraph.new($1, current_speaker, $2)
        end
      end

      paragraphs
    end
  end
end
