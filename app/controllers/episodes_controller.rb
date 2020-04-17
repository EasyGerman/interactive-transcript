class EpisodesController < ApplicationController
  def show
    # Find episode

    episode_key = params[:id]

    # - if any of these is present in the description => pick that episode
    identifier_strings = [
      "_transkript_#{episode_key}.html",
      "https://easygermanpodcastplayer.herokuapp.com/episodes/#{episode_key}",
      episode_url(episode_key),
    ].uniq

    @xml = Nokogiri::XML(rss)

    # - search through all episodes
    episode_node = @xml.css('item').find do |episode_node|
      description_html = episode_node.css('description').text

      identifier_strings.any? do |identifier_string|
        description_html.include?(identifier_string)
      end
    end

    if episode_node.blank?
      raise ActionController::RoutingError.new('Episode not found')
    end

    @episode = Episode.new(episode_node)
    @title = @episode.title
  end

  private

  def rss
    Rails.cache.fetch("feed", expires_in: 5.minutes) do
      require 'open-uri'
      open(ENV.fetch('PODCAST_URL')).read
    end
  end
end
