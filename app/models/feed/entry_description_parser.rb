class Feed
  class EntryDescriptionParser
    extend Memoist

    TranscriptHeaderNotFound = Class.new(StandardError)

    delegate :podcast, to: :episode

    def initialize(html, episode)
      @html = Corrector.correct_feed_entry_description(html, episode.slug)
      @episode = episode
    end

    # def access_key
    #   # TODO: remove hardcoded podcasts
    #   case episode.podcast.code
    #   when 'easygerman'
    #     if html =~ %r{egp(\w+)_transkript(_(\w{12,}))?.html} # TODO: localize
    #       code, _, secret = $1, $2, $3
    #       secret || code
    #     end
    #   else
    #     if html =~ %r{https://www.dropbox.com/s/(\w+)/#{episode.podcast.code}podcast(.*)_transcript.html\?dl=1} # TODO: localize
    #       secret, _ = $1, $2
    #       secret
    #     end
    #   end
    # end

    def transcript_player_url
      urls.find { |key, value| key.downcase == 'transcript player' }&.[](1)
    end

    def urls
      html_node.css('a').map { |element| [element.text, element.attr('href')] }.to_h
    end

    def vocab_url
      if html =~ %r{https://www.easygerman.org/s/(\w+)_vokabeln(_(\w+))?.(txt|rtf)} # TODO: localize
        Regexp.last_match[0]
      end
    end

    memoize def downloadable_html_url
      html_node.at_css('a:contains("HTML")')&.attr('href')
    end

    def transcript_header?(node)
      node.name.in?(podcast.header_tags) && node.text.strip == podcast.transcript_title
    end

    memoize def transcript_start_index
      # TODO: move to corrector
      if episode.slug == 'our-podcast-how-31006226'
        nodes.index { |node| node.text.include?("[0:00]") }
      else
        i = nodes.index(&method(:transcript_header?))
        raise TranscriptHeaderNotFound if i.nil?
        i + 1
      end
    end

    # HTML fragment containing the show notes - will be rendered
    memoize def notes_html
      tmp_nodes = nodes[0 .. transcript_start_index - 2]

      if podcast.code == 'easycatalan' && episode.slug == 'trailer'
        if hr_index = transcript_nodes.index { |node| node.name == 'hr' }
          tmp_nodes += transcript_nodes[..(hr_index - 1)]
        end
      end

      tmp_nodes.map(&:to_html).join("\n").html_safe
    rescue TranscriptHeaderNotFound
      nodes.map(&:to_html).join("\n").html_safe
    end

    memoize def transcript_nodes
      nodes[transcript_start_index .. -1]
    end

    attr_reader :html, :episode

    memoize def html_node
      Nokogiri::HTML(html)
    end

    def node
      html_node
    end

    def nodes
      node.css('body > *').to_a
    end

    def pretty_html
      html_node.to_html(indent: 2, indent_text: ' ')
    end
  end
end
