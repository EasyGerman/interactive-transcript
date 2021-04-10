class PreciseTimestamp
  def self.from(object)
    return object if object.is_a?(self)
    return from(object.to_s) if object.is_a?(Timestamp)
    return nil if object.nil?
    return new(object) if object.is_a?(Integer) || object.is_a?(Float)
    return parse(object) if object.is_a?(String)
    raise ArgumentError, "can't build from #{object.class}"
  end

  def self.parse(s)
    seconds_str, minutes_str, hours_str = s.split(":").reverse
    new(seconds_str.to_f + minutes_str.to_i * 60 + hours_str.to_i * 3600)
  end

  def self.convert_to_seconds(s)
    from(s).to_seconds
  end

  def initialize(seconds)
    @seconds = seconds
  end

  def to_s
    # milliseconds = ((x % 1) * 1000).round.to_s.rjust(3, '0')
    total_milliseconds = (@seconds * 1000).round
    milliseconds = total_milliseconds % 1000
    total_seconds = total_milliseconds / 1000

    milliseconds_str = milliseconds.to_s.rjust(3, '0')

    seconds_str = (total_seconds % 60).to_s.rjust(2, '0')
    rest = total_seconds / 60
    minutes = rest % 60
    hours = rest / 60
    return "#{minutes}:#{seconds_str}.#{milliseconds_str}" if hours == 0
    minutes_str = minutes.to_s.rjust(2, '0')
    "#{hours}:#{minutes_str}:#{seconds_str}.#{milliseconds_str}"
  end

  def to_seconds
    @seconds
  end
end
