require "rails_helper"

describe TimedTextInterpolator do
  def transform(input_timed_text_as_array)
    input = TimedText.from_array(input_timed_text_as_array)
    described_class.call(input: input).to_array
  end

  it { expect(transform([13, " Hola a tothom!", 25, " "])).to eq [13, " Hola ", 17, "a ", 21, "tothom!", 25, " "] }
end
