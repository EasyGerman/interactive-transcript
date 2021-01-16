module Util
  module_function

  def log_to_stdout(level = Logger::INFO)
    Rails.logger = Logger.new($stdout).tap { |logger| logger.level = level }
  end

  def debug_to_stdout
    log_to_stdout(Logger::DEBUG)
  end
end
