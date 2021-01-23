class Admin::TimedParagraphsController < AdminController
  def show
    @episode = load_episode(params[:episode_id])
    @paragraph = @episode.timed_script.paragraphs.find { |p| p.signature == params[:id] }
  end
end
