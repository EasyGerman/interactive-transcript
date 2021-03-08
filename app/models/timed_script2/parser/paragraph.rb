class TimedScript2::Parser::Paragraph
  attr_accessor :speaker, :start_time, :end_time, :children, :previous_paragraph, :next_paragraph

  def initialize
    @children = []
  end

  def as_json
    { speaker: speaker&.as_json, start_time: start_time, children: children.map(&:as_json) }
  end

  def to_txt
    [
      "P #{speaker.to_txt} #{Timestamp.from_any_object(start_time)&.to_s}-#{Timestamp.from_any_object(end_time)&.to_s}",
      *children.map { |child| Txt.bullet('-', child.is_a?(String) ? child.inspect : child.to_txt) },
    ].join("\n")
  end
end
