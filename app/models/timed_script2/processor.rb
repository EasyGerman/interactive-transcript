class TimedScript2::Processor < Operation

  attribute :parsed_paragraph, ::Types::Instance(TimedScript2::Parser::Paragraph)

  def call
    Debug.log("#{self.class.name} #{parsed_paragraph.as_json.inspect}") do
      TimedScript::Paragraph.new(
        Timestamp.from_seconds(parsed_paragraph.start_time).to_s,
        parsed_paragraph.speaker,
        to_slices(parsed_paragraph.children, TimeRange.new(parsed_paragraph.start_time, parsed_paragraph.next_paragraph&.start_time)),
      )
    end
  end

  def to_slices(nodes, time_range)
    timed_text = TimedText.new
    process_items_to_stream(timed_text, nodes, time_range)
    Debug.log("timed_text: #{timed_text.array.inspect}")
    slices = timed_text.array.in_groups_of(2).map do |timestamp, text|
      ['', timestamp, text]
    end.tap do |result|
      Debug.log("slices: #{result.inspect}")
    end
  end

  def process_items_to_stream(timed_text, nodes, time_range)
    if time_range.start_time
      # Debug.log("start => append_or_replace_timestamp #{time_range.start_time}")
      timed_text.append_or_replace_timestamp(time_range.start_time)
    end
    nodes.each do |node|
      if node.is_a?(String)
        timed_text.append_text(node)
      else
        sub_time_range = TimeRange.new(node.start_time, node.end_time)
        Debug.log("range: #{time_range}, sub: #{sub_time_range}") do
          sub_time_range = sub_time_range.constrained_to(time_range)#.constrained_to(TimeRange.new(timed_text.last_timestamp, nil))
          Debug.log("constrained range: #{sub_time_range}")
          process_items_to_stream(timed_text, node.children, sub_time_range)
        end
      end
    end
    if time_range.end_time
      # Debug.log("end => append_timestamp #{time_range.end_time}")
      timed_text.append_timestamp(time_range.end_time)
    end
  end
end
