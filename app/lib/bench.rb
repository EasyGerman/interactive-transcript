class Bench
  class << self
    attr_accessor :level
  end

  self.level = 0

  def self.m(label)
    return yield unless ENV['BENCH']
    ret = nil
    duration = Benchmark.realtime do
      self.level += 1
      ret = yield
      self.level -= 1
    end
    puts "[#{"%.3f" % duration}] #{"  " * level}#{label}" if duration >= 0.1
    ret
  end

end
