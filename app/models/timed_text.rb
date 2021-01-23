##
# Alternating timestamps (int) and text (string).
#
# Odd index: timestamp
# Event index: text
#
class TimedText
  attr_reader :array

  def initialize
    @array = []
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
    Debug.log("#{__method__} #{text}")
    raise ArgumentError, "text must be a string" unless text.is_a?(String)
    if last_element_text?
      if @array.any?
        @array.last << text
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

  private

  def last_element_timestamp?
    @array.count.odd?
  end

  def last_element_text?
    @array.count.even?
  end

end
