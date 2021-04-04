##
# Alternating timestamps (int) and text (string).
#
# Even index: timestamp
# Odd index: text
#
# Example:
#
#   [13, "Hello ", 14, "everybody!", 15]
#
class TimedText
  attr_reader :array

  def self.from_array(array)
    new(array: array)
  end

  def initialize(array: nil)
    @array = array || []
  end

  def append_timestamp(timestamp, replace_last: false)
    Debug.log("#{__method__} #{timestamp}")
    raise ArgumentError, "timestamp must be an integer" unless timestamp.is_a?(Integer)
    return if timestamp == last_timestamp

    if last_element_timestamp?
      if replace_last
        @array.pop
      else
        append_text ''
      end
    end
    @array << timestamp
  end

  def append_or_replace_timestamp(timestamp)
    append_timestamp(timestamp, replace_last: true)
  end

  def append_text(text)
    Debug.log("#{__method__} #{text.inspect}")
    raise ArgumentError, "text must be a string" unless text.is_a?(String)
    if last_element_text?
      if @array.any?
        @array[-1] = @array[-1] + text
      else
        @array << nil
        @array << text
      end
    else
      @array << text
    end
  end

  def last_timestamp
    return if @array.empty?
    last_element_timestamp? ? @array[-1] : @array[-2]
  end

  def to_array
    @array
  end

  def transform_each_text_surrounded_by_timestamps
    new_array = []
    array.each_with_index do |item, index|
      if index % 2 == 1 && index < array.count - 1
        transformed = yield array[index - 1], item, array[index + 1]
        new_array.concat(transformed)
      else
        new_array << item
      end
    end
    @array = new_array
    self
  end

  private

  def last_element_timestamp?
    @array.count.odd?
  end

  def last_element_text?
    @array.count.even?
  end

end
