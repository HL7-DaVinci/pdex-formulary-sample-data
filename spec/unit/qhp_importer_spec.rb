# frozen_string_literal: true

require_relative '../../lib/formulary/qhp_importer'

RSpec.describe Formulary::QHPImporter do
  let(:repo) { class_double('Formulary::QHPDrugRepo') }
  let(:qhp_data) do
    [
      [{ abc: '123' }, { def: '456' }],
      [{ ghi: '789' }, { jkl: '012' }]
    ]
  end
  let(:urls) { ['http://example.com/1', 'http://example.com/2'] }
  let(:importer) { Formulary::QHPImporter.new(urls, repo) }

  describe '.initialize' do
    it 'creates a QHPImporter instance' do
      expect(importer).to be_a(Formulary::QHPImporter)
    end
  end

  describe '.import' do
    before(:each) do
      urls.zip(qhp_data).each do |request|
        url = request.first
        json = request.last
        stub_request(:get, url)
          .to_return(body: json.to_json)
      end
    end

    it 'loads QHP data from the provided urls and calls import on the repo' do
      expect(repo).to receive(:import).with(qhp_data.flatten)
      importer.import
    end
  end
end
