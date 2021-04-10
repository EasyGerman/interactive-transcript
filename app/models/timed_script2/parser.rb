class TimedScript2::Parser

  DEBUG = true

  attr_reader :paragraphs

  def initialize(doc)
    @paragraphs = []
    @context = {}
    new_paragraph
    process_children(doc.css('#transcript'))
  end

  def process_children(node, level: 0)
    node.children.each do |child|
      process(child, level: level + 1)
    end
  end

  def process(node, level:)
    debug_node(node, level: level) do
      case node.name
      when 'h2' then
      when 'b' then add_speaker(node)
      when 'small' then
        if node.attribute("style").value.include?("opacity: 0.5;")
          add_paragraph_timestamp(node)
        end
      when 'span' then
        if node.attribute("data-start").present? && node.attribute("data-end").present?
          add_timing(node.attribute("data-start").value, node.attribute("data-end").value) do
            process_children(node, level: level + 1)
          end
        elsif node.attribute("title").present?
          add_timing(node.attribute("title").value) do
            process_children(node, level: level + 1)
          end
        else
          process_children(node, level: level + 1)
        end
      when 'text' then
        add_text(node)
      when 'div' then
        process_children(node, level: level + 1)
      else
        if node.element?
          process_children(node, level: level + 1)
        end
      end
    end
  end

  def debug_node(node, level:)
    if node.name == "text"
      Debug.log("Text: #{node.text.inspect}") { yield }
    else
      s = "<#{
        [node.name, *node.attributes.map { |key, a| "#{a.name}=#{a.value}" unless a.name == 'style' }].compact.join(" ")
      }>"
      Debug.log(s) { yield }
    end
  end

  def with_context(new_context_attributes)
    original_context = @context
    @context = @context.merge(new_context_attributes)
    yield
  ensure
    @context = original_context
  end

  def new_paragraph
    Debug.log("#{__method__} (#{@paragraphs.count})")
    previous_paragraph = @paragraph
    @paragraphs << (@paragraph = Paragraph.new)
    @paragraph.previous_paragraph = previous_paragraph
    @context[:cursor] = nil
    previous_paragraph.next_paragraph = @paragraph if previous_paragraph
  end

  def current_paragraph
    new_paragraph if @paragraph.nil?
    @paragraph
  end

  def add_speaker(node)
    Debug.log(__method__)
    new_paragraph unless current_paragraph.start_time.nil?
    current_paragraph.speaker = Speaker.new(
      id: node.attribute('data-spk')&.value,
      name: node.text.sub(/:$/, '')
    )
  end

  def add_paragraph_timestamp(node)
    current_paragraph.start_time = PreciseTimestamp.convert_to_seconds filter_text(node.text)[/^\s*\[?(.*?)\]?\s*$/, 1] || raise("time not found in: #{node.text.inspect}")
  end

  def cursor
    @context[:cursor] || current_paragraph
  end

  def add_timing(start_time, end_time = nil)
    Debug.log(__method__) do
      timing = Timing.new(start_time, end_time)
      timing.parent = cursor
      cursor.children << timing
      with_context(cursor: timing) do
        yield
      end
    end
  end

  def add_text(node)
    Debug.log(__method__)
    text = filter_text(node.text)

    if (last_text = cursor.children.last).is_a?(String)
      cursor.children[cursor.children.count - 1] = filter_text(last_text + text)
    else
      cursor.children << text# unless text =~ /^\s+$/
    end
  end

  def filter_text(text)
    text.gsub("\u00A0", ' ').gsub(/\s+/m, ' ')
  end
end
