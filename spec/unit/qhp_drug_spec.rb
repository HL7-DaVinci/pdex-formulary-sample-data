# frozen_string_literal: true

require 'json'
require 'pry'
require_relative '../../lib/formulary/qhp_drug'

RSpec.describe Formulary::QHPDrug do
  let(:raw_drugs) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_drugs.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_drug) { raw_drugs.first }

  let(:drug) do
    Formulary::QHPDrug.new(raw_drug)
  end

  describe '.initialize' do
    it 'creates a QHPDrug instance' do
      expect(drug).to be_a(Formulary::QHPDrug)
    end
  end

  describe '#rxnorm_code' do
    it 'returns the rxnorm code for the drug' do
      expect(drug.rxnorm_code).to eq('RXNORM_ID_1')
    end
  end

  describe '#name' do
    it 'returns the drug name' do
      expect(drug.name).to eq('DRUG_NAME_1')
    end
  end

  describe '#plans' do
    it 'returns the plan info for the drug' do
      plans = raw_drug[:plans]
      expect(drug.plans).to eq(plans)
    end
  end
end
