class TimedScript
  Paragraph = Struct.new(:timestamp_string, :speaker, :slices)
  Paragraph.class_eval do
    extend Memoist

    memoize def timestamp
      Timestamp.new(timestamp_string)
    end

    def text
      slices.flat_map { |slice| [slice[0], slice[2]] }.join.strip
    end

    memoize def signature
      Digest::MD5.hexdigest("#{timestamp_string}-#{text}")[0..7]
    end

    def segments
      Bench.m("#{self.class.name}##{__method__}") do

        timed_segments =
          Bench.m("#{self.class.name}##{__method__} SplitProcessor") do
            TimedScript::SplitProcessor.call(slices, timestamp_string)
          end

        timed_segments.map do |time, text|
          Segment.new(time || timestamp_string, text)
        end
      end
    end
  end

  Word = Struct.new(:timestamp_string, :text)
end
