class TranscriptFromFeed
  extend Memoist
  include ErrorHandling

  # TODO: try to remove episode_description, it doesn't belong here
  attr_reader :nodes, :episode_description

  def initialize(nodes, episode_description)
    @nodes = nodes
    @episode_description = episode_description
  end

  memoize def chapters
    chapters = []
    current_chapter = nil

    nodes.each do |node|
      if node.name == 'h3'
        chapters << current_chapter = Chapter.new(node.text.strip, [], episode_description, chapters.size)
      elsif node.name == 'p'
        if current_chapter.blank?
          chapters << current_chapter = Chapter.new(nil, [], episode_description, chapters.size)
        end
        current_chapter.paragraphs << Paragraph.new(node, current_chapter, current_chapter.paragraphs.size)
      else
        raise "Unexpected format: #{node.to_html}"
      end
    end

    chapters
  end

end
