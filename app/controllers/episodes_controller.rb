class EpisodesController < ApplicationController
  def index
    @xml = Nokogiri::XML(rss)
  end

  def show
    @xml = Nokogiri::XML(rss)
    @episode = @xml.css('item')[params[:id].to_i - 1]
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
