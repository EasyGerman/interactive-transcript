require 'spec_helper'
require_relative __FILE__.sub('/spec/', '/app/').sub('_spec.rb', '.rb')

describe EpisodeIdentifiers do

  subject(:instance) {
    described_class.new(
      entry_link_url: entry_link_url,
      transcript_player_url: transcript_player_url,
      downloadable_html_url: downloadable_html_url,
    )
  }

  let(:access_key) { instance.access_key }
  let(:short_name) { instance.short_name }

  context 'for regular episodes' do
    let(:entry_link_url) { 'https://shows.acast.com/easyeaspanish/episodes/1'}
    let(:transcript_player_url) { 'https://play.easyspanish.fm/episodes/abcdefghijklmno' }
    let(:downloadable_html_url) { 'https://www.dropbox.com/s/bcdefghijklmnop/easyspanishpodcast1_transcript.html?dl=1' }

    it 'uses the episode number as short name' do
      expect(short_name).to eq '1'
    end

    it 'uses the hash from the transcript player url as access key' do
      expect(access_key).to eq 'abcdefghijklmno'
    end

    context 'if there is no transcript_player_url' do
      let(:transcript_player_url) { nil }

      it 'uses the hash from the downloadable html as access key' do
        expect(access_key).to eq 'bcdefghijklmnop'
      end
    end

    context 'if the string after /posts/ starts with number followed by dash' do
      let(:entry_link_url) { 'https://www.patreon.com/posts/111-bitte-12345678'}
      let(:transcript_player_url) { 'https://play.easyspanish.fm/episodes/abcdefghijklmno' }
      let(:downloadable_html_url) { 'https://www.easygerman.org/s/egp111_transkript_bcdefghijklmnop.html' }

      it 'uses the numeric component as short name' do
        expect(short_name).to eq '111'
      end
    end
  end

  context 'for special episodes' do
    let(:entry_link_url) { 'https://shows.acast.com/easyeaspanish/episodes/pilot'}
    let(:transcript_player_url) { 'https://play.easyspanish.fm/episodes/abcdefghijklmno' }
    let(:downloadable_html_url) { 'https://www.dropbox.com/s/bcdefghijklmnop/easyspanishpodcastPILOT_transcript.html?dl=1' }

    it 'uses the string after /episodes/ as short_name' do
      expect(short_name).to eq 'pilot'
    end
  end

  context 'for trailer episodes / 0' do
    let(:entry_link_url) { 'https://shows.acast.com/easyeaspanish/episodes/trailer'}
    let(:transcript_player_url) { 'https://play.easyspanish.fm/episodes/abcdefghijklmno' }
    let(:downloadable_html_url) { 'https://www.dropbox.com/s/bcdefghijklmnop/easyspanishpodcast0_transcript.html?dl=1' }

    it 'uses the number 0 as short_name' do
      expect(short_name).to eq '0'
    end
  end

  context 'for easygerman "how-to" episode' do
    let(:entry_link_url) { 'https://www.patreon.com/posts/our-podcast-1234567'}
    let(:transcript_player_url) { 'https://play.easyspanish.fm/episodes/abcdefghijklmno' }
    let(:downloadable_html_url) { 'https://www.easygerman.org/s/egpPATREON_transkript_bcdefghijklmnop.html' }

    it 'uses "patreon"' do
      expect(short_name).to eq 'patreon'
    end
  end

  context 'for easygerman "zwischending" episodes' do
    let(:entry_link_url) { 'https://www.patreon.com/posts/zwischending-1234567'}
    let(:transcript_player_url) { nil }
    let(:downloadable_html_url) { nil }

    it 'uses the url component after /posts/ as short_name' do
      expect(short_name).to eq 'zwischending-1234567'
    end

    it 'has no access_key' do
      expect(access_key).to eq nil
    end
  end
end
