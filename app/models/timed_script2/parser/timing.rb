#
# Represents start/end time for a section of text.
#
class TimedScript2::Parser::Timing
  attr_accessor :start_time, :end_time, :children, :parent

  def initialize(start_time, end_time)
    @start_time = Timestamp.convert_string_to_seconds(start_time) if start_time
    @end_time = Timestamp.convert_string_to_seconds(end_time) if end_time
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
    prefix = "T #{Timestamp.from_any_object(start_time)&.to_s}-#{Timestamp.from_any_object(end_time)&.to_s}"
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
