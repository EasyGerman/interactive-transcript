# Description of a feed entry
#
# Responsibilities:
# - find access key in the content
# - make corrections
# - exposes a prettified html
# - finds downloadable (txt/rtf) vocab url
# - exposes a Vocab object
# - decides whether to take transcript from file or feed based on episode date and delegates to the appropriate transcript processing object
# - exposes nokogiri html_node
# - exposes html with timestamps tagged (delegates to Timestamp)
# - parses HTML, recognizes <p>, .timestamp, adds them to TranslationCache, and adds data-translation-id to the <p> tag, exposes final html
# - exposes nokogiri nodes in the body
# - finds the Notes section and exposes it as HTML
# - finds the transcript nodes and exposes them
# - finds the downloadable_html_url
# - exposes paragraph objects
# - exposes sentences
#
class EpisodeDescription
  extend Memoist
  include ErrorHandling

  TranscriptHeaderNotFound = Class.new(StandardError)

  attr_reader :html, :episode

  delegate :chapters, to: :transcript, allow_nil: true

  def initialize(fetcher, html, episode)
    @fetcher = fetcher
    @html = html
    @episode = episode

    if episode.title == '23: Das deutsche Gesundheitssystem'
      @html.sub!('[59:4]', '[59:44]')
    end
  end

  def pretty_html
    html_node.to_html(indent: 2, indent_text: ' ')
  end

  def access_key
    if html =~ %r{egp(\w+)_transkript(_(\w{12,}))?.html}
      code, _, secret = $1, $2, $3
      secret || code
    end
  end

  def vocab_url
    if html =~ %r{https://www.easygerman.org/s/(\w+)_vokabeln(_(\w+))?.(txt|rtf)}
      Regexp.last_match[0]
    end
  end

  memoize def vocab
    Vocab.new(vocab_url) if vocab_url.present?
  end

  memoize def transcript
    if Date.parse(episode.node.at_css('pubDate')) >= Date.parse("2020-10-13 00:00 UTC") && downloadable_html_url.present?
      ::TranscriptFromFile.new(downloadable_html, self)
    else
      ::TranscriptFromFeed.new(transcript_nodes, self)
    end
  rescue TranscriptHeaderNotFound
    if downloadable_html_url.present?
      ::TranscriptFromFile.new(downloadable_html, self)
    end
  end

  memoize def downloadable_html
    return @fetcher.fetch_downloadable_transcript(episode) if @fetcher.present?

    # TODO: move to fetcher
    URI.open(downloadable_html_url).read
  end

  memoize def html_node
    Nokogiri::HTML(html)
  end

  memoize def html_with_timestamps_tagged
    Timestamp.tag_in_html(html)
  end

  def processed_html
    nokogiri_html = Nokogiri::HTML(html_with_timestamps_tagged)
    nokogiri_html.css('p').each do |node|
      if node.css('.timestamp').length > 0
        node['class'] = "timestampedEntry"
        hide_and_report_errors do
          text = Paragraph.new(node).text
          translation_cache = TranslationCache.add_original_nx(text)
          node['data-translation-id'] = translation_cache.key
        end
      end
    end
    nokogiri_html.css('body').children.to_html.html_safe
  end


  memoize def nodes
    Nokogiri::HTML(html_with_timestamps_tagged).css('body > *').to_a
  end

  memoize def notes_html
    nodes[0 .. transcript_start_index - 2].map(&:to_html).join("\n").html_safe
  rescue TranscriptHeaderNotFound
    nodes.map(&:to_html).join("\n").html_safe
  end

  memoize def transcript_nodes
    nodes[transcript_start_index .. -1]
  end

  memoize def downloadable_html_url
    html_node.at_css('a:contains("HTML")')&.attr('href')
  end

  private def transcript_header?(node)
    node.name == 'h3' && node.text.strip == 'Transkript'
  end

  private memoize def transcript_start_index
    if episode.slug == 'our-podcast-how-31006226'
      nodes.index { |node| node.text.include?("[0:00]") }
    else
      i = nodes.index(&method(:transcript_header?))
      raise TranscriptHeaderNotFound if i.nil?
      i + 1
    end
  end

  def paragraphs
    Nokogiri::HTML(html_with_timestamps_tagged).css('p').to_a
      .select { |node|
        node.css('.timestamp').length > 0
      }
      .reject { |node| node.text.blank? }
      .map { |node| Paragraph.new(node) }
  end

  def sentences
    paragraphs.flat_map(&:sentences)
  end

end
