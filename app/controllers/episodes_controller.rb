class EpisodesController < ApplicationController
  caches_page :show

  def show
    access_key = params[:id].presence or raise "access key missing"

    @feed = Feed.new

    @episode = @feed.episodes.find { |ep| ep.access_key == access_key }
    if @episode.blank?
      raise ActionController::RoutingError.new('Episode not found')
    end
    @title = @episode.title
  end
end
