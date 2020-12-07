class Feed
  class EntryDescriptionParser
    extend Memoist

    TranscriptHeaderNotFound = Class.new(StandardError)

    def initialize(html, episode)
      @html = Corrector.correct_feed_entry_description(html, episode.slug)
      @episode = episode
    end

    def access_key
      if html =~ %r{egp(\w+)_transkript(_(\w{12,}))?.html} # TODO: localize
        code, _, secret = $1, $2, $3
        secret || code
      end
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
      node.name == 'h3' && node.text.strip == 'Transkript' # TODO: localize
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
      nodes[0 .. transcript_start_index - 2].map(&:to_html).join("\n").html_safe
    rescue TranscriptHeaderNotFound
      nodes.map(&:to_html).join("\n").html_safe
    end

    memoize def transcript_nodes
      nodes[transcript_start_index .. -1]
    end

    private

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
  end
end
