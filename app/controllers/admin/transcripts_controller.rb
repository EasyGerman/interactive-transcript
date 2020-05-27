class Admin::TranscriptsController < AdminController
  def index
    @records = EpisodeRecord.all
  end

  def create
    uploaded_io = params[:transcript_file]

    attributes =
      params.permit(:access_key, :slug, :transcript)
        .merge(transcript: uploaded_io.read)

    @record = EpisodeRecord.create!(attributes)

    flash[:notice] = "Episode transcript added."
    redirect_to action: :index
  end
end
