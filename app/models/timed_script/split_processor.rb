##
# Processes the reuslt of a split by the timestamp tag and returns a list of
# timestamped words as an array of [time, text].
#
class TimedScript::SplitProcessor
  class << self
    def call(slices, start_time)
      Debug.log("#{self.name}.#{__method__} #{slices.inspect}, #{start_time.inspect}")
      clean_up_inbetweeners(slices)
        .then(&method(:instantiate_segments))
        .then { |segments| segments[0].time ||= start_time; segments }
        .then(&method(:split_words))
        .then(&method(:unite_broken_words))
        .then(&method(:distribute_evenly))
        .then(&method(:strip_spaces))
        .map(&:to_a)
    end

    # Process items that are inbetween timestamp tags
    def clean_up_inbetweeners(slices)
      slices.each_with_index do |item, index|
        pre, time, content = item
        if pre.length > 0
          if index == 0
            item[2] = "#{pre.lstrip}#{item[2]}"
            item[0] = ""
          else
            slices[index - 1][2] << pre
            item[0] = ""
          end
        end
      end

      slices.pop if slices.last == ["", nil, nil]

      slices.map do |_pre, time, content|
        [time, content]
      end
    end

    def instantiate_segments(items)
      items.map { |item| Segment.new(*item) }
    end

    def split_words(items)
      Debug.log("#{self.name}.#{__method__} #{items.inspect}") do
        items.flat_map do |segment|
          segment.text.split(%r{(?<= )}).map do |word|
            Segment.new(segment.time, word)
          end
        end
      end
    end

    def unite_broken_words(segments)
      segments.each_consecutive_pair do |a, b|
        SegmentPair.new(a, b)
          .tap(&:prefer_trailing_space)
          .tap(&:unite_words)
      end
      segments.reject(&:blank?)
    end

    def distribute_evenly(segments)
      numbers = segments.map(&:time).map(&Timestamp.method(:convert_to_seconds))
      new_numbers = distribute_numbers_evenly(numbers.dup)
      segments.each_with_index do |segment, index|
        if new_numbers[index] != numbers[index]
          segment.time = Timestamp.from_any_object(new_numbers[index]).to_s
        end
      end
      segments
    end

    def strip_spaces(segments)
      segments.first.text.sub!(/^\s+/, '')
      segments.last.text.sub!(/\s+$/, '')
      segments
    end

    def distribute_numbers_evenly(a)
      stretch_start_index = 0
      a.each_with_index do |x, i|
        next if i == 0
        prev = a[i - 1]
        increase = x - prev

        if increase > 1 && stretch_start_index < i - 1
          unit = increase / (i - stretch_start_index).to_f
          (stretch_start_index + 1 .. i - 1).each_with_index do |j, strech_index|
            a[j] = (a[j] + unit * (strech_index + 1)).round
          end
        end

        stretch_start_index = i if increase > 0
      end
    end
  end

  #------------------------------------------------------------

  ##
  # A piece of text with a timestamp
  #
  class Segment
    attr_accessor :time, :text

    delegate :blank?, to: :text

    def initialize(time, text)
      @time = time
      @text = text || ""
    end

    def [](index)
      return time if index == 0
      return text if index == 1
      raise ArgumentError
    end

    def []=(index, value)
      return self.time = value if index == 0
      return self.text = value if index == 1
      raise ArgumentError
    end

    def to_a
      [time, text]
    end
  end

  #------------------------------------------------------------

  ##
  # Two consecutive segments
  #
  class SegmentPair
    attr_reader :a, :b

    def initialize(a, b)
      @a, @b = a, b
    end

    ##
    # Move leading space from the beginning of the second segment to the end of the first one
    #
    def prefer_trailing_space
      if b.text =~ %r{^(\s+)(.*)$}
        space, _ = $1, $2
        shift_backward(space)
      end
    end

    ##
    # When a word is split between 2 segments, move the shorted spit to the other segment
    #
    def unite_words
      _, a_rest, a_word = %r{^(.* )?(\w+)$}.match(a.text).to_a # a ends with word character
      _, b_word, b_rest = %r{^(\w+\s*)(.* )?$}.match(b.text).to_a # b starts with word character

      if a_word && b_word
        if a_word.length > b_word.length
          shift_backward(b_word)
        else
          shift_forward(a_word)
        end
      end
    end

    def shift_backward(shiftee)
      a.text.concat(shiftee)
      b.text.delete_prefix!(shiftee)
    end

    def shift_forward(shiftee)
      a.text.delete_suffix!(shiftee)
      b.text.prepend(shiftee)
    end
  end
end
