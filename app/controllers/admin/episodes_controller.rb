class Admin::EpisodesController < AdminController
  def index
    @feed = Feed.new
  end

  def show
    @feed = Feed.new
    @episode = @feed.episodes.find { |e| e.slug == params[:id] }
  end

  def timed_script
    @feed = Feed.new
    @episode = @feed.episodes.find { |e| e.slug == params[:id] }
    @timed_script = @episode.timed_script
  end
end
