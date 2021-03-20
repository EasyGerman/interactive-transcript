class EpisodeIdentifiers < Operation

  attribute :entry_link_url, Types::String
  attribute :transcript_player_url, Types::String.optional
  attribute :downloadable_html_url, Types::String.optional

  def access_key
    # Ideal case: the feed contains a link to Transcript Player
    # - https://play.easyspanish.fm/episodes/abcdefghijklmno
    if match = %r{\Ahttps://play\.easy[a-z]+\.fm/episodes/(?<access_key>[a-zA-Z0-9]+)}.match(transcript_player_url)
      return match.named_captures.fetch('access_key')
    end

    # In case there is no link to Transcript Player, fall back to the "Download Transcript as HTML" link
    if download_link_match
      return download_link_match.named_captures.fetch('access_key')
    end
  end

  def short_name
    # Ideal case: the download link contains short name (0, 1, 2, PILOT, etc)
    if download_link_match
      name = download_link_match.named_captures.fetch('short_name')
      # PILOT => pilot
      return name.downcase
    end

    # Fallback: use the <link> tag in the RSS feed entry
    # - https://shows.acast.com/easyeaspanish/episodes/1
    # - https://shows.acast.com/easyeaspanish/episodes/pilot
    # - https://www.patreon.com/posts/111-bitte-12345678
    # - https://www.patreon.com/posts/our-podcast-1234567
    # - https://www.patreon.com/posts/zwischending-1234567
    if match = %r{/(episodes|posts)/(?<path_component>[^/]+)}.match(entry_link_url)
      path_component = match.named_captures.fetch('path_component')

      if number_match = %r{\A(?<number>\d+)([\-\_])}.match(path_component)
        return number_match.named_captures.fetch('number')
      end

      return path_component
    end
  end

  private

  memoize def download_link_match
    # Ideal case: The download link is a link to Dropbox, containing the access key and also an episode short_name
    # - https://www.dropbox.com/s/bcdefghijklmnop/easyspanishpodcast1_transcript.html?dl=1
    match = %r{\Ahttps://www\.dropbox.com/s/(?<access_key>[^/]+)/easy([a-z]+)podcast(?<short_name>[a-zA-Z0-9]+)_transcript.html\?dl=1}.match(downloadable_html_url)
    return match if match.present?

    # Fallback: legacy download link for Easy German
    # - https://www.easygerman.org/s/egp111_transkript_bcdefghijklmnop.html
    # - https://www.easygerman.org/s/egpPATREON_transkript_bcdefghijklmnop.html
    %r{\Ahttps://www\.easygerman\.org/s/egp(?<short_name>[a-zA-Z0-9]+)_transkript_([^/]+).html\Z}.match(downloadable_html_url)
  end
end
