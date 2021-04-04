class Admin::TimedScript2sController < AdminController
  def show
    @episode = load_episode(params[:episode_id])
  end
end
