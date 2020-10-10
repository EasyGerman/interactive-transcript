class EpisodesController < ApplicationController
  def show
    @access_key = params[:id].presence or raise "access key missing"

    @prepared_episode = FetchPreparedEpisode.(
      access_key: @access_key,
      force_processing: (params[:reprocess] == '1'),
    )

    if @prepared_episode.blank?
      render 'not_found', status: 404
      return
    end

    @title = @prepared_episode.title
  end

end
