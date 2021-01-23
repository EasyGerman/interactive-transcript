class TimeRange
  attr_accessor :start_time, :end_time

  def initialize(start_time, end_time)
    raise ArgumentError, "start_time must be integer or nil, #{start_time.class.name} given" unless start_time.is_a?(Integer) || start_time.nil?
    raise ArgumentError, "end_time must be integer or nil, #{end_time.class.name} given" unless end_time.is_a?(Integer) || end_time.nil?
    @start_time = start_time
    @end_time = end_time
  end

  def constrained_to(constraint)
    TimeRange.new(
      constrain_time_to(start_time, constraint),
      constrain_time_to(end_time, constraint)
    )
  end

  def constrain_time_to(t, constraint)
    t = constraint.start_time if t && constraint.start_time && constraint.start_time > t
    t = constraint.end_time if t && constraint.end_time && constraint.end_time < t
    t
  end

  def to_s
    "TimeRange<#{start_time.inspect},#{end_time.inspect}>"
  end
end
