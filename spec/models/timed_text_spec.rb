require "rails_helper"

describe TimedText do
  example 'adding timestamp & text in order' do
    subject.append_timestamp(12)
    expect(subject.array).to eq([12])
    subject.append_text('hello ')
    expect(subject.array).to eq([12, 'hello '])
    subject.append_timestamp(13)
    expect(subject.array).to eq([12, 'hello ', 13])
    subject.append_text('hi ')
    expect(subject.array).to eq([12, 'hello ', 13, 'hi '])
  end

  example 'adding text first' do
    subject.append_text('hello ')
    expect(subject.array).to eq([nil, 'hello '])
    subject.append_timestamp(12)
    expect(subject.array).to eq([nil, 'hello ', 12])
    subject.append_text('hi ')
    expect(subject.array).to eq([nil, 'hello ', 12, 'hi '])
  end

  example 'adding multiple pieces of text in a row' do
    subject.append_timestamp(12)
    expect(subject.array).to eq([12])
    subject.append_text('hello ')
    expect(subject.array).to eq([12, 'hello '])
    subject.append_text('hi ')
    expect(subject.array).to eq([12, 'hello hi '])
  end

  example 'adding multiple timestamps in a row' do
    subject.append_timestamp(12)
    expect(subject.array).to eq([12])
    subject.append_timestamp(13)
    expect(subject.array).to eq([12, '', 13])
    subject.append_text('hello ')
    expect(subject.array).to eq([12, '', 13, 'hello '])
  end

  example 'transform_each_text_surrounded_by_timestamps' do
    tt = described_class.from_array([10, "hi", 11, "everybody", 12, " "])
    tt.transform_each_text_surrounded_by_timestamps do |t1, text, t2|
      [text + "ya"]
    end
    expect(tt.array).to eq([10, "hiya", 11, "everybodyya", 12, " "])
  end
end
