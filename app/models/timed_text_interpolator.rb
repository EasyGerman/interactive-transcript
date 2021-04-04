class TimedTextInterpolator < Operation
  attribute :input, Types.Instance(TimedText)

  def call
    input.transform_each_text_surrounded_by_timestamps do |t1, text, t2|
      if text.blank?
        [text]
      else
        # Split where a space follows a non-space
        split = text.split(/(?<= )(?=[^ ])/)
        if split.first =~ /\A +\Z/
          spaces = split.shift
          split[0] = "#{spaces}#{split[0]}"
        end

        duration = t2 - t1
        item_duration = duration.to_f / split.count

        split.to_enum.with_index.flat_map { |item, i| [(t1 + i * item_duration).round, item] }[1..]
      end
    end
  end
end
