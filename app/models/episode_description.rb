class EpisodeDescription
  extend Memoist
  include ErrorHandling

  TranscriptHeaderNotFound = Class.new(StandardError)

  attr_reader :html, :episode

  delegate :chapters, to: :transcript

  def initialize(html, episode)
    @html = html
    @episode = episode
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
    ::TranscriptFromFeed.new(transcript_nodes, self)
  rescue TranscriptHeaderNotFound
    html = URI.open(downloadable_html_url).read
    ::TranscriptFromFile.new(html, self)
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
    nodes[0 .. transcript_start_index - 1].map(&:to_html).join("\n").html_safe
  rescue TranscriptHeaderNotFound
    nodes.map(&:to_html).join("\n").html_safe
  end

  memoize def transcript_nodes
    nodes[transcript_start_index .. -1]
  end

  def downloadable_html_url
    html_node.at_css('a:contains("HTML")').attr('href')
  end

  def transcript_header?(node)
    node.name == 'h3' && node.text.strip == 'Transkript'
  end

  memoize def transcript_start_index
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
