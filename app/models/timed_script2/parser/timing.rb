#
# Represents start/end time for a section of text.
#
class TimedScript2::Parser::Timing
  attr_accessor :start_time, :end_time, :children, :parent

  def initialize(start_time, end_time)
    @start_time = PreciseTimestamp.from(start_time)&.to_seconds
    @end_time = PreciseTimestamp.from(end_time)&.to_seconds
    @children = []
  end

  def as_json
    {
      start_time: start_time,
      end_time: end_time,
      children: children.map(&:as_json)
    }
  end

  def to_txt
    prefix = "T #{PreciseTimestamp.from(start_time)&.to_s}-#{PreciseTimestamp.from(end_time)&.to_s}"
    Txt.bullet(
      prefix,
      children.map { |child|
        Txt.bullet(
          '-',
          child.is_a?(String) ? child.inspect : child.to_txt
        )
      }.join("\n")
    )
  end
end
