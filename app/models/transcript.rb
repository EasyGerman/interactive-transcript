class Transcript
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
    h
  end

  memoize def doc
    Nokogiri::HTML(preprocessed_html)
  end

  def inner_node
    doc.css('#transcript')
  end

  def analyze
    inner_node.to_html.split("\n").each do |line|
      case line
      when %r{^<b data-spk="(\d+)" title="">(\w+):</b><br>$}
        speaker_number, speaker_name = $1, $2
        puts speaker_name.green
      when %r{^<small style="opacity: 0.5;">\[([\d:]+)\]</small>\s*(.*)$}
        timestamp, rest = $1, $2
        rest.gsub!(%r{<br>$}, '')
        rest.gsub!(%r{<span>([^<]*)</span>}, '\\1')
        rest.gsub!(%r{<span data\-start=[^>]+>}, '')
        rest.gsub!('</span></span>', '</span>')
        puts "#{timestamp.yellow} #{rest.blue}"

        split = rest.split(%r{<span title="([^"]+)">([^<]+)</span>})
        items = []
        carry = nil
        split.each_slice(3) do |pre, time, content|
          pre = ActionView::Base.full_sanitizer.sanitize(pre)
          content = ActionView::Base.full_sanitizer.sanitize(content)
          if pre != ""
            if pre[-1] == " " && items.any?
              items.last.last << pre
              pre = ""
            end
          end
          if time
            items << [time, pre + content]
          elsif pre.present?
            if items.any?
              items.last.last << pre
            else
              [timestamp, pre]
            end
          end
        end
        pp items.group_by { |time, text| time }.map { |time, items| [time, items.map { |_, text| text }.join] }

      when %r{<h2 id="chapter">([^<]+)</h2>}
        puts line.yellow
      when '<br>', '<div>', '</div>', ''
      when %r{^<span style="background-color: rgba?\(\d+, \d+, \d+(, 0\.\d+)?\);"><br></span>$}
      when %r{^<div id="transcript"}
      when '<span><br></span>'
      else
        puts line.red
      end
    end
  end
end
