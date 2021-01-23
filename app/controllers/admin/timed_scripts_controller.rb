class Admin::TimedScriptsController < AdminController
  def show
    @episode = load_episode(params[:episode_id])
  end
end
