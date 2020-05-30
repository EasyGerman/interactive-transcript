class Admin::ParagraphsController < AdminController

  def show
    @feed = Feed.new
    @episode = @feed.episodes.find { |e| e.slug == params[:episode_id] }
    @paragraph = @episode.paragraphs.find { |p| p.slug == params[:id] }
  end

end
