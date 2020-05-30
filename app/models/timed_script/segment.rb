class TimedScript
  # A word or group of words with a timestamp
  class Segment
    extend Memoist

    attr_accessor :timestamp_string, :text, :options

    def initialize(timestamp_string, text, options = {})
      @timestamp_string = timestamp_string
      @text = text
      @options = options
    end

    memoize def timestamp
      Timestamp.new(timestamp_string)
    end
  end
end
