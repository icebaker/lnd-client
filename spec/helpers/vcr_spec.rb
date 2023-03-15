# frozen_string_literal: true

RSpec.describe VCR do
  REPLAY_EXCLAMATION_ALLOWED = [
    'spec/helpers/vcr.rb',
    'spec/helpers/vcr_spec.rb'
  ].freeze

  EXPECT_EXCLAMATION_ALLOWED = [
    'spec/helpers/vcr_spec.rb'
  ].freeze

  describe 'ensure no replay!' do
    it 'ensures no replay!' do
      Dir.glob('spec/**/*.rb').each do |file|
        content = File.read(file)
        if content =~ (/replay!/) && !REPLAY_EXCLAMATION_ALLOWED.include?(file)
          expect { raise "replay! not allowed, but found at '#{file}'" }.not_to raise_error
        end
      end
    end
  end

  describe 'ensure no expect!' do
    it 'ensures no expect!' do
      Dir.glob('spec/**/*.rb').each do |file|
        content = File.read(file)
        if content =~ (/expect!/) && !EXPECT_EXCLAMATION_ALLOWED.include?(file)
          expect { raise "expect! not allowed, but found at '#{file}'" }.not_to raise_error
        end
      end
    end
  end

  describe 'build_path_for' do
    context 'too long' do
      let(:key) do
        'lightning.decode_pay_req/lnbc10n1p374jnvpp5qrdyr668cmh7ftnmv299nfxp4sle44dam9538r9agvyqggez9gusdqs2d68ycthvfjhyunecqzpgxqyz5vqsp5492cchna2qnqlf26azlljwatuxqcck7epagtx55lvgk9uw7gn4aq9qyyssqt5xs2rhg7z4x7pj2crazw5yfesugwzf03eylvsjgumfwvufp3vzq0lk98t5lm7np9x9465p7el07q07sl8nyyxnlc767mlanr8nvuzqpp3d65y'
      end
      let(:params) { {} }

      it 'builds' do
        expect(described_class.build_path_for(key, params)).to eq(
          'spec/data/tapes/lightning/decode_pay_req/lnbc10n1p374jnvpp5qrdyr668cmh7ftnmv299nfxp4sle44dam9538r9agvyqgge/40ad699496091dd7871a4ac435a2506330f0dca8379d2743b773150679aeb6b3.bin'
        )
      end
    end

    context 'common' do
      let(:key) { 'lightning.list_invoices.first/memo/settled' }
      let(:params) { { limit: 5 } }

      it 'builds' do
        expect(described_class.build_path_for(key, params)).to eq(
          'spec/data/tapes/lightning/list_invoices/first/memo/settled/limit/5.bin'
        )
      end
    end

    context '2 levels' do
      let(:key) { 'lightning.lookup_invoice' }
      let(:params) { { fetch: { lookup_invoice: false } } }

      it 'builds' do
        expect(described_class.build_path_for(key, params)).to eq(
          'spec/data/tapes/lightning/lookup_invoice/fetch/lookup_invoice/false.bin'
        )
      end
    end

    context 'reels' do
      let(:key) { 'lightning.list_invoices.first/memo/settled' }
      let(:params) { { limit: 5 } }

      it 'builds' do
        expect(described_class.build_path_for(key, params, kind: :reels)).to eq(
          'spec/data/reels/lightning/list_invoices/first/memo/settled/limit/5.bin'
        )
      end
    end
  end
end
