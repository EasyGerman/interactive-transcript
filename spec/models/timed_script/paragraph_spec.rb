require "rails_helper"

describe TimedScript::Paragraph do
  let(:body) {
    'Ja, i<span data-start="00:00:21.864" data-end="00:00:23.874"'\
    ' data-spk="1" data-label="Manuel"><span title="0:22">ch</span> '\
    '<span title="0:22">hab</span><span title="0:22"> schon</span> '\
    '<span title="0:23">mich</span> <span>ein bisschen gewundert.</span>'\
    '</span><br>'
  }
  let(:speaker) { TimedScript::Speaker.new('1', 'Manuel') }
  subject(:instance) { described_class.new('0:22', speaker, body) }

  it "provides segments" do
    expect(subject.segments.map(&:text)).to eq(
      [
        "Ja, ",
        "ich ",
        "hab ",
        "schon ",
        "mich ",
        "ein ",
        "bisschen ",
        "gewundert.",
      ]
    )
  end


  describe "#segments" do
    let(:subject) { instance.segments }

    context "when the paragraph starts with untimestamped words" do
      let(:body) { 'Ja, <span title="0:22">ich</span>' }

      it "connects the initial segment to the first timestamped segment" do
        expect(subject.first.timestamp_string).to eq '0:22'
        expect(subject.first.text).to eq 'Ja, '
      end
    end

    context "when the opening tag is in the middle of a word" do
      let(:body) { '<span title="0:01">Hallo</span> Ma<span title="0:02">nuel</span>'}

      it "treats the word as a unit" do
        expect(subject[1].text.strip).to eq 'Manuel'
        expect(subject[1].timestamp_string).to eq '0:02'
      end
    end

    context "when the closing tag is in the middle of a word" do
      let(:body) { '<span title="0:01">Hallo</span> <span title="0:02">Manu</span>el'}

      it "treats the word as a unit" do
        expect(subject[1].text.strip).to eq 'Manuel'
        expect(subject[1].timestamp_string).to eq '0:02'
      end
    end

    context "example: fuer mich" do
      let(:body) {
        '<span data-start="01:17:46.331" data-end="01:17:46.641" data-spk="0" data-label="Cari"><span title="1:17:46">Ja, das … Für m</span></span><span data-start="01:17:50.861" data-end="01:17:57.901" data-spk="0" data-label="Cari"><span title="1:17:51">ich</span>'
      }

      it "treats the word as a unit" do
        expect(subject.map(&:text)).to eq(
          [
            "Ja, ",
            "das ",
            "… ",
            "Für ",
            "mich"
          ]
        )
      end
    end

    context "when there's no timestamp tag" do
      let(:body) { 'Hallo' }

      it "adds a timestamp" do
        expect(subject.map(&:text)).to eq(['Hallo'])
        expect(subject.first.timestamp_string).to eq "0:22"
      end
    end

    context do
      let(:body) {
        '<span title="43:15">auf</span> <span title="43:15">jede</span><span title="43:15">n</span> <span title="43:15">zugehe</span>'
      }

      it do
        expect(subject.map(&:text)).to eq(
          [
            "auf ",
            "jeden ",
            "zugehe"
          ]
        )
      end
    end

    context "if there is a space at the end" do
      let(:body) {
        '<span data-start="00:03:39.324" data-end="00:03:41.134" data-spk="0" data-label="Cari"><span title="3:39">Nein,</span> <span title="3:41">echt? </span></span><br>'
      }

      it "removes the space" do
        expect(subject.map(&:text)).to eq(
          [
            "Nein, ",
            "echt?",
          ]
        )
      end
    end
  end

end
