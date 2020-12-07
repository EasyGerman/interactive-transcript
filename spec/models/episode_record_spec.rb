require 'rails_helper'

describe EpisodeRecord do
  let(:podcast) { create_podcast }

  describe 'unique index' do
    context 'if duplicate access_key within the same podcast' do
      it 'does not allow' do
        podcast.episode_records.create!(access_key: '1', data: {})
        expect {
          podcast.episode_records.create!(access_key: '1', data: {})
        }.to raise_error ActiveRecord::RecordNotUnique
      end
    end

    context 'if duplicate access_key, but different podcasts' do
      let(:other_podcast) { create_podcast }
      it 'does not allow' do
        podcast.episode_records.create!(access_key: '1', data: {})
        expect {
          other_podcast.episode_records.create!(access_key: '1', data: {})
        }.not_to raise_error ActiveRecord::RecordNotUnique
      end
    end
  end

  describe '.upsert!' do
    let(:subject) { podcast.episode_records.upsert!(access_key, {}) }
    let(:access_key) { '12' }

    context 'if episode does not exist' do
      it 'creates it' do
        expect { subject }.to change { podcast.episode_records.count }.by(1)
      end
    end
  end
end
