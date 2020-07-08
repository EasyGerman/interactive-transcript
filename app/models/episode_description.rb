class EpisodeDescription
  extend Memoist
  include ErrorHandling

  attr_reader :html, :episode

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

  memoize def chapters
    chapters = []
    current_chapter = nil

    transcript_nodes.each do |node|
      if node.name == 'h3'
        chapters << current_chapter = Chapter.new(node.text.strip, [], self, chapters.size)
      elsif node.name == 'p'
        if current_chapter.blank?
          chapters << current_chapter = Chapter.new("Intro", [], self, chapters.size)
        end
        current_chapter.paragraphs << Paragraph.new(node, current_chapter, current_chapter.paragraphs.size)
      else
        raise "Unexpected format: #{node.to_html}"
      end
    end

    chapters
  end

  memoize def notes_html
    nodes = Nokogiri::HTML(html_with_timestamps_tagged).css('body > *').to_a
    i = nodes.index { |node| node.name == 'h3' && node.text.strip == 'Transkript' }
    nodes[0 .. i].map(&:to_html).join("\n").html_safe
  end

  memoize def transcript_nodes
    nodes = Nokogiri::HTML(html_with_timestamps_tagged).css('body > *').to_a
    i = nodes.index { |node| node.name == 'h3' && node.text.strip == 'Transkript' }
    nodes[i + 1 .. -1]
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
