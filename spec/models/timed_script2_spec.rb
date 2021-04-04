require "rails_helper"

xdescribe TimedScript2 do
  let(:transcript_editor_html) {
    <<~HTML
    <div id="transcript" class="transcript-base" contenteditable="false">

    <h2 id="chapter">Intro</h2>
    <b data-spk="0" title="">Cari:</b><br>
    <small style="opacity: 0.5;">[0:15]</small>
    <span data-start="00:00:14.924" data-end="00:00:16.134" data-spk="0" data-label="Cari"><span title="0:15">Hallo!</span></span><br>
    <br>
    <b data-spk="1" title="">Manuel:</b><br>
    <small style="opacity: 0.5;">[0:16]</small>
    <span data-start="00:00:16.464" data-end="00:00:17.434" data-spk="1" data-label="Manuel"><span title="0:16">Hallo</span>&nbsp;<span>Cari!</span></span><br>
    <br>
    <b data-spk="0" title="">Cari:</b><br>
    <small style="opacity: 0.5;">[0:20]</small>&nbsp;Ich
    hab heute m<span data-start="00:00:19.704" data-end="00:00:21.334" data-spk="0" data-label="Cari"><span title="0:20">al</span>
    <span title="0:20">nicht</span>
    <span title="0:20">mitgesungen.</span></span><br>
    <br>
    <b data-spk="1" title="">Manuel:</b><br>
    <small style="opacity: 0.5;">[0:22]</small>&nbsp;Ja,
    i<span data-start="00:00:21.864" data-end="00:00:23.874" data-spk="1" data-label="Manuel"><span title="0:22">ch</span>
    <span title="0:22">hab</span><span title="0:22">&nbsp;schon</span>&nbsp;<span title="0:23">mich</span>&nbsp;<span>ein bisschen gewundert.</span></span><br>
    <br>

    HTML
  }
  subject(:instance) { described_class.new(transcript_editor_html) }

  describe ".parsed_paragraphs" do
    subject(:parsed_paragraphs) { instance.parsed_paragraphs }

    it "returns object representation of the information in HTML" do
      txt = parsed_paragraphs.flat_map(&:to_txt).join("\n")
      expect(txt).to eq <<~TXT.strip
        P Cari (0) 0:15-
        - " "
        - T 0:14-0:16 - T 0:15- - "Hallo!"
        - " "
        P Manuel (1) 0:16-
        - " "
        - T 0:16-0:17 - T 0:16- - "Hallo"
                      - " Cari!"
        - " "
        P Cari (0) 0:20-
        - " Ich hab heute m"
        - T 0:19-0:21 - T 0:20- - "al"
                      - " "
                      - T 0:20- - "nicht"
                      - " "
                      - T 0:20- - "mitgesungen."
        - " "
        P Manuel (1) 0:22-
        - " Ja, i"
        - T 0:21-0:23 - T 0:22- - "ch"
                      - " "
                      - T 0:22- - "hab"
                      - T 0:22- - " schon"
                      - " "
                      - T 0:23- - "mich"
                      - " ein bisschen gewundert."
        - " "
      TXT

    end
  end

  it "breaks it down into paragraphs and timestamped segments" do
    expect(subject.paragraphs[0].speaker.name).to eq "Cari"
    expect(subject.paragraphs[0].text).to eq "Hallo!"
    expect(subject.paragraphs[0].timestamp.to_s).to eq "0:15"
    expect(subject.paragraphs[0].segments[0].text).to eq "Hallo!"

    expect(subject.paragraphs[3].segments[0].text).to eq "Ja, "
    expect(subject.paragraphs[3].segments[1].text).to eq "ich "

    expect(subject.as_plain_text.strip).to eq <<~TEXT.strip
      0:15|Hallo!|

      0:16|Hallo |
      0:17|Cari!|

      0:20|Ich |
      0:20|hab |
      0:20|heute |
      0:21|mal |
      0:21|nicht |
      0:21|mitgesungen.|

      0:22|Ja, |
      0:22|ich |
      0:22|hab |
      0:22|schon |
      0:23|mich |
      0:23|ein |
      0:23|bisschen |
      0:23|gewundert.|
    TEXT
  end

  Dir[Rails.root.join('spec', 'fixtures', 'timed_script', '*')].each do |dir|
    name = File.basename(dir)

    it "processes example #{name.inspect}" do
      transcript_editor_html = File.read("#{dir}/input.html")
      instance = described_class.new(transcript_editor_html)
      expected_plain_text =
        begin
          File.read("#{dir}/output.txt").strip
        rescue Errno::ENOENT
          nil
        end

      if expected_plain_text
        expect(instance.as_plain_text).to eq expected_plain_text
      else
        File.open("#{dir}/output.txt", "w") { |f| f.write(instance.as_plain_text) }
      end
    end
  end

end
