class EpisodesController < ApplicationController
  caches_page :show

  before_action :prepare_feed_and_episode
  before_action :prepare_experimental, only: [:a, :dev_compare]

  def show
    @chapters_data =
      @episode.audio.chapters.to_enum.with_index.map { |chapter, index|
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
  end

  private

  def prepare_feed_and_episode
    @access_key = params[:id].presence or raise "access key missing"

    @feed = Feed.new

    @episode = @feed.episodes.find { |ep| ep.access_key == @access_key }
    if @episode.blank?
      raise ActionController::RoutingError.new('Episode not found')
    end
    @title = @episode.title
  end

  def prepare_experimental
    @chapters = filter_by_param(:c, @episode.chapters)
  end

  def filter_by_param(param_name, items)
    value = params[param_name]
    return items unless value

    [items[value.to_i]]
  end
end
