class Admin::PodcastsController < AdminController
  before_action :load_feed

  def show
    @podcast = current_podcast
  end

  private

  def load_feed
    @feed = Feed.new(current_podcast)
  end

  memoize def current_podcast
    Podcast.find_by!(code: params[:id])
  end
end
