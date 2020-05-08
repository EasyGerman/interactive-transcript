class WordMatch
  attr_reader :word, :segments

  def initialize(word, segments)
    @word = word
    @segments = segments
  end

  def matches
    segments.select { |s|
      word.in?(s)
    }
  end
end
