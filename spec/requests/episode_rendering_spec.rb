require "rails_helper"

RSpec.describe "Episode rendering", type: :request, vcr: true do
  let!(:podcast) { find_or_create_podcast('easygerman') }

  it "renders episode" do
    podcast.settings['translations'] = { enabled: true }
    podcast.save!

    get "/episodes/1", headers: { "Host" => podcast.host }

    # Limit the length, so that the RSpec output is not too much
    content_beginning = response.body.first(100_000)
    content_end = response.body.last(100_000)

    expect(content_beginning).to include('<title>1: Los geht&#39;s! - The Easy German Podcast')
    expect(content_beginning).to include('data-chapters="[{&quot;id&quot;:&quot;chp0&quot;')
    expect(content_beginning).to include('<h1>1: Los geht&#39;s!</h1>')
    expect(content_beginning).to include('<select name="language" id="language-picker">')
    expect(content_beginning).to include('<option data-service="DeepL" value="EN">English</option>')
    expect(content_beginning).to include('<h3><strong>Transkript und Vokabeln</strong></h3>')
    expect(content_beginning).to include('<h2>Transkript</h2>')
    expect(content_end).to include('title="1:04:52">Auf </span><span')
  end

end
