class EpisodesController < ApplicationController
  layout "application2", :only => [ :show_v2 ]

  def show
    show_v2
  end

  def show_v1
    prepare_data
    render action: :show, layout: "application"
  end

  def show_v2
    prepare_data
    render action: :show_v2, layout: "application2"
  end

  private

  def prepare_data
    @access_key = params[:id].presence or raise "access key missing"

    @podcast = current_podcast

    @prepared_episode = FetchPreparedEpisode.(
      podcast: @podcast,
      access_key: @access_key,
      force_processing: (params[:reprocess] == '1'),
    )

    if @prepared_episode.blank?
      render 'not_found', status: 404
      return
    end

    @title = @prepared_episode.title
    @public = (@access_key =~ /^\d+$/)
  end

end
