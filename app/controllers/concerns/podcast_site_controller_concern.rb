##
# Applies to controllers that are available on a podcast-specific domain, e.g.
# play.easygerman.fm or play.easygreek.fm
#
module PodcastSiteControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :current_podcast

    rescue_from PodcastNotFound do |e|
      render plain: "Error 404 - Not found (host not found: #{e.host})", status: 404
    end

    helper_method def current_podcast
      @current_podcast ||=
        SelectCurrentPodcast.call(
          host: request.host,
          code: params[:podcast].presence,
          env: Rails.env.to_s,
          podcasts: Podcast.all.to_a,
        )
    end

  end
end
