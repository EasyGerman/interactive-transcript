class TimedScript2::Paragraph < CustomStruct
  attribute :speaker, ::Types::Any
  attribute :timestamp, ::Types::Any
  attribute :slices, ::Types::Any
  attribute :segments, ::Types::Any

  def text
    segments.map(&:text).join
  end

  memoize def segments_as_plain_text
    segments.map do |segment|
      [segment.timestamp_string, segment.text, ''].join('|')
    end.join("\n")
  end
end
