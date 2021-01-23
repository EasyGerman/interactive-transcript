##
# Applies to controllers that are available on a podcast-specific domain, e.g.
# play.easygerman.fm or play.easygreek.fm
#
module PodcastSiteControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :current_podcast
    around_action :switch_locale

    rescue_from PodcastNotFound do |e|
      render plain: "Error 404 - Not found (host not found: #{e.host})", status: 404
    end

    helper_method def current_podcast
      @current_podcast ||=
        if Rails.env.development? && params[:podcast].present?
          @current_podcast ||= Podcast.find_by!(code: params[:podcast])
        else
          @current_podcast ||= Podcast.find_by_request!(request)
        end
    end

    def switch_locale(&action)
      locale = current_podcast.locale || I18n.default_locale
      if locale == 'de'
        I18n.with_locale(locale, &action)
      else
        action.call
      end
    end
  end
end
