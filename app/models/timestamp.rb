class Timestamp
  REGEX = %r{\[((\d{1,2}:)?\d{1,2}:\d{2})\]?}
  CORE_REGEX = %r{(((?<hours>\d{1,2}):)?(?<minutes>\d{1,2}):(?<seconds>\d{2}))}

  def self.tag_in_html(html)
    html.gsub(REGEX) do |m|
      timestamp_string = $1
      sec = convert_string_to_seconds(timestamp_string)
      "<span class='timestamp' data-timestamp='#{sec}'>[#{timestamp_string}]</span>"
    end.html_safe
  end

  def self.convert_string_to_seconds(string)
    raise ArgumentError, "expected a string, got #{string.inspect} (#{string.class.name})" if !string.is_a?(String)
    string.split(":").reverse.to_enum.with_index.map { |x, i| x.to_i * (60 ** i) }.sum
  end

  def self.from_any_object(object)
    return object if object.is_a?(self)
    return nil if object.nil?
    return self if object.is_a?(self)
    return from_seconds(object) if object.is_a?(Integer) || object.is_a?(Float)
    return new(object) if object.is_a?(String)
    raise ArgumentError, "can't build from #{object.class}"
  end

  def self.convert_to_seconds(object)
    return nil if object.nil?
    return to_seconds if object.is_a?(self)
    return object if object.is_a?(Integer) || object.is_a?(Float)
    return convert_string_to_seconds(object) if object.is_a?(String)
    raise ArgumentError, "can't convert from #{object.class}"
  end

  attr_reader :string
  alias to_s string

  def initialize(string)
    raise ArgumentError, "expected a string, got #{string.inspect} (#{string.class.name})" if !string.is_a?(String)
    if m = CORE_REGEX.match(string)
      @string = [m[:hours], m[:minutes], m[:seconds]].compact.join(":")
    else
      @string = string
    end
  end

  def to_seconds
    self.class.convert_string_to_seconds(string)
  end

  def -(x)
    if x.is_a?(Timestamp)
      # Difference between 2 Timestamps
      # TODO: new class Duration
      self.class.from_seconds(to_seconds - x.to_seconds)
    else
      # Subtact duration from a Timestamp
      self.class.from_seconds(to_seconds.seconds - x)
    end
  end

  def self.from_seconds(x)
    x = x.to_i
    seconds = (x % 60).to_s.rjust(2, '0')
    rest = x / 60
    minutes = rest % 60
    hours = rest / 60
    return new("#{minutes}:#{seconds}") if hours == 0
    minutes = minutes.to_s.rjust(2, '0')
    new("#{hours}:#{minutes}:#{seconds}")
  end

  def processed
    ::Processed::Timestamp.new(
      text: string,
      seconds: to_seconds,
    )
  end

end
