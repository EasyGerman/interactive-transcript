class TranscriptFromFile
  extend Memoist
  include ErrorHandling

  attr_reader :html, :episode_description

  def initialize(html, episode_description)
    @html = html
    @episode_description = episode_description
  end

  memoize def collector
    { chapters: [] }
  end

  def current_chapter
    add_chapter("Intro") if collector[:chapters].empty?
    collector[:chapters].last
  end

  def add_chapter(title)
    collector[:chapters] << { title: title, paragraphs: [] }
  end

  def current_paragraph
    add_paragraph if current_chapter[:paragraphs].empty?
    current_chapter[:paragraphs].last
  end

  def add_paragraph(speaker = nil)
    current_chapter[:paragraphs] << { speaker: speaker, texts: [] }
  end

  def add_text(text)
    current_paragraph[:texts] << text unless text.blank?
  end

  memoize def chapters
    Nokogiri::HTML(html).css('.transcript-base').children.each do |child|
      parse_nokogiri_element(child)
    end

    collector[:chapters].to_enum.with_index.map do |chapter_hash, chapter_index|
      chapter = Chapter.new(
        self,
        chapter_hash[:title],
        [],
        episode_description,
        chapter_index,
      )

      chapter_hash[:paragraphs].to_enum.with_index.each do |paragraph_hash, paragraph_index|
        text = [paragraph_hash[:speaker], " ", *paragraph_hash[:texts]].join
        chapter.paragraphs << Paragraph.new(
          text,
          chapter,
          paragraph_index,
        )
      end

      chapter
    end
  end

  private

  def parse_nokogiri_element(element)
    case element
    when Nokogiri::XML::Text
      add_text(element.text)
    when Nokogiri::XML::Element
      case element.name
      when "h2", "h3", "h4"
        add_chapter(element.text.strip)
      when "b"
        add_paragraph(element.text.strip)
      when "br"
        # do nothing
      when "small"
        add_text(element.text)
      when "i", "b", "u", "em", "strong", "font", "p"
        add_text(element.text)
      when "script"
        # nothing
      when "div"
        # Recursively parse the contents of the div
        element.children.each do |child|
          parse_nokogiri_element(child)
        end
      else raise "unexpected tag: #{element.name}"
      end
    else raise "unexpected element: #{element.class.name}"
    end
  end

end
