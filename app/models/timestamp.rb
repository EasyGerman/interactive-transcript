class Timestamp
  REGEX = %r{\[((\d{1,2}:)?\d{1,2}:\d{2})\]}

  def self.tag_in_html(html)
    html.gsub(REGEX) do |m|
      timestamp_string = $1
      sec = convert_string_to_seconds(timestamp_string)
      "<span class='timestamp' data-timestamp='#{sec}'>[#{timestamp_string}]</span>"
    end.html_safe
  end

  def self.convert_string_to_seconds(string)
    string.split(":").reverse.to_enum.with_index.map { |x, i| x.to_i * (60 ** i) }.sum
  end

  attr_reader :string
  alias to_s string

  def initialize(string)
    @string = string
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
end
