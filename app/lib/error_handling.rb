module ErrorHandling
  def hide_and_report_errors
    yield
  rescue StandardError => error
    Rollbar.error(error)
    nil
  end
end
