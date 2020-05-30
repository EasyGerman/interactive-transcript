module ApplicationHelper

  def rescue_and_show_errors
    yield
  rescue StandardError => error
    render 'admin/shared/exception', error: error
  end

end
