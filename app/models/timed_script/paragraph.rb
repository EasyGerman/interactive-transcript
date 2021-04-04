class TimedScript
  Paragraph = Struct.new(:timestamp_string, :speaker, :slices)
  Paragraph.class_eval do
    extend Memoist

    memoize def timestamp
      Timestamp.new(timestamp_string) if timestamp_string.present?
    end

    memoize def text
      slices.flat_map { |slice| [slice[0], slice[2]] }.join.strip
    end

    memoize def signature
      Digest::MD5.hexdigest("#{timestamp_string}-#{text}")[0..7]
    end

    memoize def segments
      Bench.m("#{self.class.name}##{__method__}") do

        timed_segments =
          Bench.m("#{self.class.name}##{__method__} SplitProcessor") do
            TimedScript::SplitProcessor.call(slices, timestamp_string)
          end

        timed_segments.map do |time, text|
          Segment.new(Timestamp.from_any_object(time || timestamp_string).to_s, text)
        end
      end
    end

    memoize def segments_as_plain_text
      segments.map do |segment|
        [segment.timestamp_string, segment.text, ''].join('|')
      end.join("\n")
    end
  end

  Word = Struct.new(:timestamp_string, :text)
end
