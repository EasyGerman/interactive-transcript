class PicturesController < ApplicationController

  def show
    access_key = params[:episode_id].presence or raise "access key missing"
    chapter_id = params[:chapter_id]

    @feed = Feed.new

    @episode = @feed.episodes.find { |ep| ep.access_key == access_key }
    if @episode.blank?
      raise ActionController::RoutingError.new('Episode not found')
    end

    @chapter = @episode.audio.chapters.find { |c| c.id == chapter_id }

    if @chapter.picture.blank?
      raise ActionController::RoutingError.new('Picture not found')
    end

    send_data @chapter.picture.data, type: 'image/jpeg', disposition: 'inline'
  end
end
