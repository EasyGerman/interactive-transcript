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
    @episode = @xml.css('item').find do |episode_node|
      description_html = episode_node.css('description').text

      identifier_strings.any? do |identifier_string|
        description_html.include?(identifier_string)
      end
    end

    if @episode.blank?
      raise ActionController::RoutingError.new('Episode not found')
    end

    @title = @episode.css('title').first.text
    @html = Nokogiri::HTML(@episode.css('description').text)

    @audio_url = @episode.css('enclosure').first["url"]

    html = @episode.css('description').text
    @processed_html = html.gsub(%r{\[((\d{1,2}:)?\d{1,2}:\d{2})\]}) do |m|
      sec = $1.split(":").reverse.to_enum.with_index.map { |x, i| x.to_i * (60 ** i) }.sum
      "<span class='timestamp' data-timestamp='#{sec}'>[#{$1}]</span>"
    end
  end

  private

  def rss
    Rails.cache.fetch("feed", expires_in: 5.minutes) do
      require 'open-uri'
      open(ENV.fetch('PODCAST_URL')).read
    end
  end
end
