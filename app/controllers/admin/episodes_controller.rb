class Admin::EpisodesController < AdminController
  before_action :load_feed
  before_action :load_episode, except: [:index]

  def index
  end

  def show
  end

  def timed_script
    @timed_script = @episode.timed_script
  end

  private

  def load_feed
    @feed = Feed.new(current_podcast)
  end

  def load_episode
    @episode = @feed.episodes.find { |e| e.slug == params[:id] }
    raise "Episode not found: #{params[:id]}" if @episode.blank?
  end
end
