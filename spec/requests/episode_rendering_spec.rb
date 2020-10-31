require "rails_helper"

RSpec.describe "Episode rendering", type: :request, vcr: true do

  it "renders episode" do
    get "/episodes/1"

    expect(response.body).to include('<title>1: Los geht&#39;s!</title>')
    expect(response.body).to include('data-chapters="[{&quot;id&quot;:&quot;chp0&quot;')
    expect(response.body).to include('<h1>1: Los geht&#39;s!</h1>')
    expect(response.body).to include('<select name="language" id="language-picker"><option value="EN">English</option>')
    expect(response.body).to include('<h3><strong>Transkript und Vokabeln</strong></h3>')
    expect(response.body).to include('<h2>Transkript</h2>')
    expect(response.body).to include('title="1:04:52">Auf </span><span')
  end

end
