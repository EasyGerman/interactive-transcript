class TimedScript2::Parser::Speaker
  attr_accessor :id, :name

  def initialize(id:, name:)
    @id = id
    @name = name
  end

  def as_json
    { id: id, name: name }
  end

  def to_txt
    "#{name} (#{id})"
  end
end
