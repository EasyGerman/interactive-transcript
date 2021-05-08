require 'patreon'
require 'pry'

class PatreonAuthController < ApplicationController
  include PodcastSiteControllerConcern

  skip_before_action :current_podcast, except: [:start]

  SCOPES = %w[
    identity
    identity.memberships
  ]

  def start
    redirect_to "https://www.patreon.com/oauth2/authorize?response_type=code&client_id=#{ENV.fetch('PATREON_CLIENT_ID')}&scope=#{SCOPES.join("%20")}&redirect_uri=#{PatreonOauthAdapter.redirect_uri}&state=#{current_podcast.id}"
  end

  def info
  end

  def redirect
    Rails.logger.info "redirect params: #{params.inspect}"
    podcast = Podcast.find(params[:state])

    if request.host != host_for_env(podcast.host)
      Rails.logger.info "Redirecting to correct podcast: #{request.host} -> #{host_for_env(podcast.host)}"
      redirect_to "#{url_for_env(podcast.host)}#{request.path}?code=#{params[:code]}&state=#{params[:state]}"
      return
    end

    patreon_user = PatreonOauthAdapter.new.find_or_create_patreon_user_from_code(params[:code])
    session[:patreon_user_id] = patreon_user.patreon_user_id
    redirect_to root_url
  end

  def logout
    session[:patreon_user_id] = nil
    render plain: 'OK'
  end

  private

  def oauth_redirect_url
    url_for_env(current_podcast.host) + "/patreon/redirect"
  end

end
