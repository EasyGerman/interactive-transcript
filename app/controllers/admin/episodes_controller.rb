class Admin::EpisodesController < AdminController
  def index
    @episode_records = EpisodeRecord.all
  end

  def create
    @episode_record = EpisodeRecord.create!(params.permit(:access_key, :slug, :transcript))
    flash[:notice] = "Episode transcript added."
    redirect_to action: :index
  end
end
