class ApplicationController < ActionController::Base

  extend Memoist

  def current_user
    return if session[:patreon_user_id].blank?
    PatreonUser.find_by(patreon_user_id: session[:patreon_user_id])
  end
  memoize :current_user
  helper_method :current_user

  def host_for_env(host)
    URI.parse(url_for_env(host)).host
  end
  helper_method :host_for_env

  def url_for_env(host)
    if Rails.env.development? && request.host.end_with?(".dev.levs.tools")
      "https://#{host}.dev.levs.tools"
    elsif Rails.env.development? || Rails.env.test?
      "http://#{host.sub(/\.fm\Z/, '.local')}:5600"
    else
      "https://#{host}"
    end
  end

end
