module ErrorHandling
  def hide_and_report_errors
    if Rails.env.production?
      begin
        yield
      rescue StandardError => error
        Rails.logger.error("Error: #{error.class.name}: #{error.message} #{error.backtrace.first}")
        Rollbar.error(error)
        nil
      end
    else
      yield
    end
  end
end
