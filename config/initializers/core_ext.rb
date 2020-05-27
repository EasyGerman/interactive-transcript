Array.class_eval do
  def each_consecutive_pair
    first = true
    prev = nil
    each do |item|
      if first
        first = false
      else
        yield(prev, item)
      end
      prev = item
    end
  end
end
