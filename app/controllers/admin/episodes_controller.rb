class Admin::EpisodesController < AdminController
  def index
    @feed = Feed.new
    # @episode_records = EpisodeRecord.all
  end

  def show
    @feed = Feed.new
    @episode = @feed.episodes.find { |e| e.slug == params[:id] }
  end
end
