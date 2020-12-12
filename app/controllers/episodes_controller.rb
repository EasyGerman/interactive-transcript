class EpisodesController < ApplicationController
  layout "application2", :only => [ :show_v2 ]

  def show
    case cookies[:version]&.to_i
    when 1 then show_v1
    when 2 then show_v2
    else show_v2
    end
  end

  def show_v1
    prepare_data
    cookies[:version] = 1
    render action: :show, layout: "application" unless performed?
  end

  def show_v2
    prepare_data
    cookies[:version] = 2
    render action: :show_v2, layout: "application2" unless performed?
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
