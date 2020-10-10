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
      case child
      when Nokogiri::XML::Text
        add_text(child.text.strip)
      when Nokogiri::XML::Element
        case child.name
        when "h4"
          add_chapter(child.text.strip)
        when "b"
          add_paragraph(child.text.strip)
        when "br"
          # do nothing
        when "small"
          add_text(child.text.strip)
        else raise "unexpected tag: #{child.name}"
        end
      else raise "unexpected element: #{child.class.name}"
      end
    end

    collector[:chapters].to_enum.with_index.map do |chapter_hash, chapter_index|
      chapter = Chapter.new(
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

end
