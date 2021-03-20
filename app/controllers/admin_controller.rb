class AdminController < ApplicationController
  extend Memoist
  http_basic_authenticate_with name: "admin", password: ENV.fetch('ADMIN_PASSWORD', SecureRandom.hex(64))

  layout "admin"
  helper Admin::ApplicationHelper

  memoize def current_podcast
    Podcast.find_by!(code: params[:podcast_id])
  end
  helper_method :current_podcast

  def load_episode(slug)
    feed = Feed.new(current_podcast)
    episode = feed.episodes.find { |e| e.slug == slug }
    raise "Episode not found by slug: #{slug}" if episode.blank?
    episode
  end
end
