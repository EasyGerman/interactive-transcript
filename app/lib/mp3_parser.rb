class Mp3Parser
  extend Memoist

  def initialize(content)
    @content = content
  end

  memoize def results
    ret = {}
    Mp3Info.open(StringIO.new(@content)) do |m|
      ret[:chapters] = m.tag2.CHAP&.map { |s| Chapter.new(s) }
      ret[:duration] = m.length
    end
    ret
  end

  def chapters
    results[:chapters] || []
  end

  def duration
    results[:duration]
  end

  class Chapter
    attr_reader :id, :start_time, :end_time, :props, :picture

    def initialize(str)
      @id, rest = str.split("\x00", 2)
      io = StringIO.new(rest)
      io.extend(Mp3Info::Mp3FileMethods)

      @start_time   = io.get32bits
      @end_time     = io.get32bits
      @start_offset = io.get32bits
      @end_offset   = io.get32bits
      @props = {}

      until io.eof? do
        name = io.read(4)
        size = io.get32bits
        io.seek(2, IO::SEEK_CUR) # skip flags
        @props[name] = io.read(size)
      end

      @picture = Picture.new(@props["APIC"]) if @props.key?("APIC")
    end
  end

  class Picture
    attr_reader :data
    def initialize(str)
      str =~ /^.([^\0]*)\0.([^\0]*)\0(.*)$/m
      @mime_type, @description, @data = $1, $2, $3
    end
  end
end
