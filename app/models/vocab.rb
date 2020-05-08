class Vocab
  extend Memoist

  attr_reader :url

  def initialize(url)
    @url = url
  end

  def ext
    File.extname(url)
  end

  memoize def raw_content
    CachedNetwork.fetch(url)
  end

  memoize def plain_text_content
    to_plain_text(raw_content)
  end

  memoize def lines
    plain_text_content
      .split("\n")
      .then(&method(:strip_header))
      .reject(&:blank?)
  end

  def to_plain_text(content)
    return content unless ext == '.rtf'
    require 'ruby-rtf'
    parser = RubyRTF::Parser.new
    parser.parse(content).sections.map do |val|
      val[:text]
    end.join
  end

  def strip_header(lines)
    raise "unexpected line 1: #{lines[0]}" if lines[0] !~ %r{\d+:}
    raise "unexpected line 2: #{lines[1]}" if lines[1] != "The Easy German Podcast"
    raise "unexpected line 3: #{lines[2]}" if lines[2] != ""
    lines[3..]
  end

  memoize def entries
    lines.map do |line|
      begin
        Entry.new(line)
      rescue Entry::Invalid => e
        # puts "WARNING: #{e.message} in #{url}"
        nil
      end
    end.compact
  end

  class Entry
    Invalid = Class.new(StandardError)
    attr_reader :de, :en

    def initialize(line)
      @de, @en = line.split(" - ")
      @en || raise(Invalid, "invalid line: #{line.inspect}")
    end

    def to_s
      "#{de} - #{en}"
    end
  end
end
