class TranscriptFromFeed
  extend Memoist
  include ErrorHandling

  attr_reader :nodes, :episode

  def initialize(feed_entry_description_parser, episode)
    @feed_entry_description_parser = feed_entry_description_parser
    @nodes = feed_entry_description_parser.transcript_nodes
    @episode = episode
  end

  memoize def chapters
    chapters = []
    current_chapter = nil

    nodes.each do |node|
      if node.name == 'h3'
        chapters << current_chapter = Chapter.new(self, node.text.strip, [], episode, chapters.size)
      elsif node.name == 'p'
        if node.children.count == 1 && node.children.first.name == "strong"
          chapters << current_chapter = Chapter.new(self, node.text.strip, [], episode, chapters.size)
          next
        end
        if current_chapter.blank?
          chapters << current_chapter = Chapter.new(self, nil, [], episode, chapters.size)
        end
        next if node.text.blank?
        current_chapter.paragraphs << Paragraph.new(node, current_chapter, current_chapter.paragraphs.size)
      else
        raise "Unexpected format: #{node.to_html}"
      end
    end

    chapters
  end

end
