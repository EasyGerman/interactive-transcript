module Debug
  module_function

  ENABLED = ENV['DEBUG'].present?

  def log(s)
    return if !ENABLED
    debug_nesting = (Thread.current[:debug_nesting] ||= 0)
    indent = " " * 4 * debug_nesting
    puts "#{indent}#{s}"
    if block_given?
      begin
        Thread.current[:debug_nesting] = debug_nesting + 1
        yield
      ensure
        Thread.current[:debug_nesting] = debug_nesting
      end
    end

  end
end
