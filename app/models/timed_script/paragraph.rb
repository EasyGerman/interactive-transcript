class TimedScript
  Paragraph = Struct.new(:timestamp_string, :speaker, :body)
  Paragraph.class_eval do
    extend Memoist

    memoize def timestamp
      Timestamp.new(timestamp_string)
    end

    def text
      sanitize(body).strip
    end

    memoize def signature
      Digest::MD5.hexdigest("#{timestamp_string}-#{text}")[0..7]
    end

    def transformed_body
      body
        .gsub(%r{<br>$}, '')
        .gsub(%r{<span>([^<]*)</span>}, '\\1')
        .gsub(%r{<span data\-start=[^>]+>}, '')
        .gsub('</span></span>', '</span>')
        .strip
    end

    def segments_from(time, text)
      text.split(%r{(?<= )}).map do |word|
        Segment.new(time, word)
      end
    end

    def segments
      Bench.m("#{self.class.name}##{__method__}") do
        split =
          Bench.m('slice') {
            transformed_body.split(%r{<span title="([^"]+)">([^<]+)</span>})
          }
        items = []
        slices =
          Bench.m('clean') {
            split.each_slice(3).map do |pre, time, content|
              # Text that falls between/outside span tags
              pre = sanitize(pre)
              content = sanitize(content)
              [pre, time, content]
            end
          }

        timed_segments =
          Bench.m("#{self.class.name}##{__method__} SplitProcessor") do
            TimedScript::SplitProcessor.call(slices, timestamp_string)
          end

        timed_segments.map do |time, text|
          Segment.new(time || timestamp_string, text)
        end
      end
    end


    def sanitize(s)
      re = /<("[^"]*"|'[^']*'|[^'">])*>/
      s&.gsub(re, '')
    end
  end

  Word = Struct.new(:timestamp_string, :text)
end
