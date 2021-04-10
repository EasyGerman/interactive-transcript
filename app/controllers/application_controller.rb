class ApplicationController < ActionController::Base

  extend Memoist

  def current_user
    return if session[:patreon_user_id].blank?
    PatreonUser.find_by(patreon_user_id: session[:patreon_user_id])
  end
  memoize :current_user
  helper_method :current_user

  def host_for_env(host)
    if Rails.env.development? || Rails.env.test?
      host.sub(/\.fm\Z/, '.local')
    else
      host
    end
  end
  helper_method :host_for_env

end
