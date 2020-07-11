module ErrorHandling
  def hide_and_report_errors
    if Rails.env.production?
      begin
        yield
      rescue StandardError => error
        Rollbar.error(error)
        nil
      end
    else
      yield
    end
  end
end
