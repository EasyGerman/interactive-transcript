class Admin::ParagraphsController < AdminController

  def show
    @episode = load_episode(params[:episode_id])
    @paragraph = @episode.chapters.flat_map(&:paragraphs).find { |p| p.slug == params[:id] }
  end

end
