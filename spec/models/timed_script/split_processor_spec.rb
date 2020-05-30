require "rails_helper"

describe TimedScript::SplitProcessor do
  it "works" do
    expect(TimedScript::SplitProcessor.call([
      ["Ja, i", "0:22", "ch"],
      [" ", "0:22", "hab"],
      ["", "0:22", " schon"],
      [" ", "0:23", "mich"],
      [" ein bisschen gewundert.", nil, nil],
    ], "0:22")).to eq([
      ["0:22", "Ja, "],
      ["0:22", "ich "],
      ["0:22", "hab "],
      ["0:22", "schon "],
      ["0:23", "mich "],
      ["0:23", "ein "],
      ["0:23", "bisschen "],
      ["0:23", "gewundert."],
    ])
  end

  it "unites broken words" do
    expect(TimedScript::SplitProcessor.call([
      ["i", "0:22", "ch"],
      [" h", "0:22", "a"],
      ["b ", "0:22", "s"],
      ["", "0:23", "cho"],
      ["n mich gewundert.", nil, nil],
    ], "0:22")).to eq([
      ["0:22", "ich "],
      ["0:22", "hab "],
      ["0:23", "schon "],
      ["0:23", "mich "],
      ["0:23", "gewundert."],
    ])
  end

  it "unites broken words" do
    expect(TimedScript::SplitProcessor.call([
      ["", "0:01", "Hallo"],
      [" Ma", "0:02", "nuel"],
    ], "0:01")).to eq([
      ["0:01", "Hallo "],
      ["0:02", "Manuel"],
    ])
  end

  it do
    expect(TimedScript::SplitProcessor.call([
      ["Hallo ", "0:01", "Cari"],
    ], "0:01")).to eq([
      ["0:01", "Hallo "],
      ["0:01", "Cari"],
    ])
  end

  it "distributes words" do
    expect(TimedScript::SplitProcessor.call([
      ["", "0:01", "a "],
      ["", "0:01", "b "],
      ["", "0:01", "c "],
      ["", "0:04", "d"],
    ], "0:01")).to eq([
      ["0:01", "a "],
      ["0:02", "b "],
      ["0:03", "c "],
      ["0:04", "d"],
    ])
  end

  it do
    expect(TimedScript::SplitProcessor.call([
      ["Nein", nil, nil],
    ], "11:11")).to eq([
      ["11:11", "Nein"],
    ])
  end

  it do
    expect(TimedScript::SplitProcessor.call([
      ["", "43:15", "auf"],
      [" ", "43:15", "jede"],
      ["", "43:15", "n"],
      [" ", "43:15", "zugehe"],
    ], "43:15")).to eq([
      ["43:15", "auf "],
      ["43:15", "jeden "],
      ["43:15", "zugehe"],
    ])
  end

  context "if there is a space at the end" do
    let(:body) {
      '<span data-start="00:03:39.324" data-end="00:03:41.134" data-spk="0" data-label="Cari"><span title="3:39">Nein,</span> <span title="3:41">echt? </span></span><br>'
    }

    it "removes the space from the end" do
      expect(TimedScript::SplitProcessor.call([
        ["", "43:15", "Nein, "],
        ["", "43:15", "echt? "],
      ], "43:15")).to eq([
        ["43:15", "Nein, "],
        ["43:15", "echt?"],
      ])
    end
  end

  describe ".distribute_numbers_evenly" do
    def call(*a)
      TimedScript::SplitProcessor.distribute_numbers_evenly(a)
    end

    it { expect(call(1, 1, 1, 4)).to eq [1, 2, 3, 4] }
    it { expect(call(1, 1, 1, 5)).to eq [1, 2, 4, 5] }
    it { expect(call(1, 1, 1, 6)).to eq [1, 3, 4, 6] }
    it { expect(call(1, 1, 1, 7)).to eq [1, 3, 5, 7] }
    it { expect(call(1, 1, 1, 10)).to eq [1, 4, 7, 10] }
    it { expect(call(1, 1, 1, 4, 4, 4, 10)).to eq [1, 2, 3, 4, 6, 8, 10] }

  end
end
