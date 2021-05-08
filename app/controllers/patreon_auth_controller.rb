require 'patreon'
require 'pry'

class PatreonAuthController < ApplicationController
  include PodcastSiteControllerConcern

  skip_before_action :current_podcast, except: [:start]

  REDIRECT_URI = "#{ENV.fetch('PATREON_OAUTH_REDIRECT_URL')}"

  def start
    redirect_to "https://www.patreon.com/oauth2/authorize?response_type=code&client_id=#{ENV.fetch('PATREON_CLIENT_ID')}&scope=identity.memberships&redirect_uri=#{REDIRECT_URI}&state=#{current_podcast.id}"
  end

  def info
  end

  def redirect
    podcast = Podcast.find(params[:state])

    # podcast_host = host_for_env(podcast.host)
    # if request.host != podcast_host
    #   scheme = Rails.env.production? ? 'https' : 'http'
    #   port_suffix = Rails.env.production? ? '' : ':5600'
    #   redirect_to "#{scheme}://#{podcast_host}#{port_suffix}#{request.path}?code=#{params[:code]}&state=#{params[:state]}"
    #   return
    # end

    oauth_client = Patreon::OAuth.new(
      ENV.fetch('PATREON_CLIENT_ID'),
      ENV.fetch('PATREON_CLIENT_SECRET'),
    )
    tokens_response = oauth_client.get_tokens(params[:code], REDIRECT_URI)

    if tokens_response.key?('error')
      Rails.logger.error("Response from Patreon get_tokens: #{tokens_response.inspect}")
      @error = "Error: Could not get authentication from Patreon: #{tokens_response['error']}"
      return
    end

    access_token = tokens_response['access_token']
    if access_token.blank?
      Rails.logger.error("Response from Patreon get_tokens: #{tokens_response.inspect}")
      @error = "Error: Could not get authentication from Patreon: token blank"
      return
    end

    api_client = Patreon::API.new(access_token)
    user_response = api_client.fetch_user()
    user = user_response.data

    patreon_user = PatreonUser.find_or_create_by!(patreon_user_id: user.id) do |patreon_user|
      patreon_user.oauth_data = tokens_response
      patreon_user.user_data = {
        pledges: user.pledges.select { |pledge| pledge.creator.id.in?(["721253"]) }.map { |pledge|
          {
            creator_id: pledge.creator.id,
            amount_cents: pledge.amount_cents,
          }
        }
      }
    end

    session[:patreon_user_id] = patreon_user.patreon_user_id
    redirect_to root_url
  end

  def logout
    session[:patreon_user_id] = nil
    render plain: 'OK'
  end

end
