class TimedScript2::Paragraph < CustomStruct
  attribute :speaker, ::Types::Any
  attribute :time, ::Types::Any
  attribute :items, ::Types::Any

  def text
    items
  end
end
