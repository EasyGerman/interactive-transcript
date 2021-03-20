require 'spec_helper'
require_relative __FILE__.sub('/spec/', '/app/').sub('_spec.rb', '.rb')

describe SelectCurrentPodcast do

  subject(:result) {
    described_class.new(
      host: host,
      code: code,
      env: env,
      podcasts: podcasts,
    ).call
  }

  let(:host) { 'play.easygreek.fm'}
  let(:code) { nil }

  let(:easygerman) { double(code: 'easygerman', host: 'play.easygerman.fm') }
  let(:easygreek) { double(code: 'easygreek', host: 'play.easygreek.fm') }
  let(:easycatalan) { double(code: 'easycatalan', host: 'play.easycatalan.fm') }

  let(:podcasts) { [easygerman, easygreek, easycatalan] }

  context 'in production' do
    let(:env) { 'production' }

    context 'if the host belongs to a podcast' do
      let(:host) { 'play.easygreek.fm'}

      it 'selects podcast based on the host' do
        expect(result).to eq easygreek
      end
    end

    context 'if the host is unrecognized' do
      let(:host) { 'play.easypeasy.fm' }

      it 'raises an error' do
        expect { result }.to raise_error(/podcast not found/i)
      end
    end

    context 'if the host has a .local tld' do
      let(:host) { 'play.easygreek.local' }

      it 'raises an error' do
        expect { result }.to raise_error(/podcast not found/i)
      end
    end

    context 'if the host is unrecognized, but a code is given' do
      let(:host) { 'localhost' }
      let(:code) { 'easycatalan' }

      it 'raises an error' do
        expect { result }.to raise_error(/podcast not found/i)
      end
    end
  end

  %w[development test].each do |iteration_env|
    context "in #{iteration_env}" do
      let(:env) { iteration_env }

      context 'if the host belongs to a podcast' do
        let(:host) { 'play.easygreek.fm'}

        it 'selects podcast based on the host' do
          expect(result).to eq easygreek
        end
      end

      context 'if the host has a .local tld' do
        let(:host) { 'play.easygreek.local' }

        it 'selects podcast based on the host' do
          expect(result).to eq easygreek
        end
      end

      context 'if the host is unrecognized' do
        let(:host) { 'play.easypeasy.fm' }

        it 'raises an error' do
          expect { result }.to raise_error(/podcast not found/i)
        end
      end

      context 'if the host is unrecognized, but a code is given' do
        let(:host) { 'localhost' }
        let(:code) { 'easycatalan' }

        it 'selects podcast based on the code' do
          expect(result).to eq easycatalan
        end
      end

    end
  end
end
