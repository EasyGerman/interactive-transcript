class TimedScript::Iterator

  attr_reader :paragraphs

  def initialize(doc)
    @paragraphs = []
    @context = {}
    new_paragraph
    process_children(doc.css('#transcript'))
  end

  def process_children(node)
    node.children.each do |child|
      process(child)
    end
  end

  def process(node)
    case node.name
    when 'h2' then
    when 'b' then add_speaker(node)
    when 'small' then
      if node.attribute("style").value.include?("opacity: 0.5;")
        add_paragraph_timestamp(node)
      end
    when 'span' then
      if node.attribute("data-start").present? && node.attribute("data-end").present?
        process_children(node)
      elsif node.attribute("title").present?
        with_context time: node.attribute("title").value do
          process_children(node)
        end
      else
        process_children(node)
      end
    when 'text' then
      add_text(node)
    when 'div' then
      process_children(node)
    else
      if node.element?
        process_children(node)
      end
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
    @paragraph = { speaker: nil, time: nil, items: [] }
    @paragraphs << @paragraph
  end

  def add_speaker(node)
    new_paragraph unless @paragraph[:time].nil?
    @paragraph[:speaker] =
      [
        node.attribute('data-spk')&.value,
        node.text.sub(/:$/, ''),
      ]
  end

  def add_paragraph_timestamp(node)
    @paragraph[:time] = filter_text(node.text)[/^\s*\[?(.*)\]?\s*$/, 1] || raise("time not found in: #{node.text.inspect}")
  end

  def add_text(node)
    if @context[:time]
      inject_timestamp_component(@context[:time])
    end
    inject_text_component(node.text)
  end

  def inject_timestamp_component(ts)
    if (para = @paragraph[:items].last) && para[1].nil? && para[2].nil?
      para[1] = ts
      para[2] = ""
    else
      @paragraph[:items] << [
        "",
        ts,
        ""
      ]
    end
  end

  def inject_text_component(text)
    if (para = @paragraph[:items].last)
      if para[2]
        para[2] = filter_text(para[2] + text)
      else
        para[0] = filter_text(para[0] + text)
      end
    else
      @paragraph[:items] << [
        filter_text(text),
        nil,
        nil,
      ]
    end
  end

  def filter_text(text)
    text.gsub("\u00A0", ' ').gsub(/\s+/m, ' ')
  end

end
