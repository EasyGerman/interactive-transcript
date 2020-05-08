class EpisodesController < ApplicationController
  caches_page :show

  def show
    access_key = params[:id].presence or raise "access key missing"

    if access_key == 'blank'
      @feed = OpenStruct.new
      @episode = OpenStruct.new
      @chapters = []
      return
    end

    @feed = Feed.new

    @episode = @feed.episodes.find { |ep| ep.access_key == access_key }
    if @episode.blank?
      raise ActionController::RoutingError.new('Episode not found')
    end
    @title = @episode.title

    @chapters = @episode.audio.chapters
    @chapters_data =
      @chapters.to_enum.with_index.map { |chapter, index|
        if chapter.picture.present?
          local_path = Rails.root.join('public', 'episodes', @episode.access_key, 'chapters', chapter.id, 'picture.jpg')
          FileUtils.mkdir_p(File.dirname(local_path))
          File.open(local_path, 'wb') { |f| f.write(chapter.picture.data) }
        end

        {
          id: chapter.id,
          start_time: chapter.start_time / 1000,
          end_time: chapter.end_time / 1000,
          has_picture: chapter.picture.present?,
        }
      }

    @mode = :word if @episode.transcript_editor_html && params[:experiment].present?
  end
end
