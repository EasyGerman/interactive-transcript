class EpisodesController < ApplicationController
  def show
    access_key = params[:id].presence or raise "access key missing"

    @feed = Feed.new

    @episode = @feed.episodes.find { |ep| ep.access_key == access_key }
    if @episode.blank?
      raise ActionController::RoutingError.new('Episode not found')
    end
    @title = @episode.title
  end

  private

  def rss
    Rails.cache.fetch("feed", expires_in: 5.minutes) do
      require 'open-uri'
      open(ENV.fetch('PODCAST_URL')).read
    end
  end
end
