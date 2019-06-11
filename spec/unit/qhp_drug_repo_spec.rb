# frozen_string_literal: true

require 'json'
require 'pry'
require_relative '../../lib/formulary/qhp_drug_repo'

RSpec.describe Formulary::QHPDrugRepo do
  let(:raw_drugs) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_drugs.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:repo) do
    Formulary::QHPDrugRepo
  end

  after(:each) do
    repo.reset!
  end

  describe '.initialize' do
    it 'creates an empty repo' do
      expect(repo.all).to be_empty
    end
  end

  describe '#import' do
    before(:each) { repo.import(raw_drugs) }

    it 'stores drugs' do
      expect(repo.all.length).to eq(raw_drugs.length)
    end

    it 'converts the drugs to QHPDrug' do
      repo.all.each do |drug|
        expect(drug).to be_a(Formulary::QHPDrug)
      end
    end
  end

  describe '#drugs_for_plan' do
    before(:each) { repo.import(raw_drugs) }

    it 'returns the drugs covered under a specified plan' do
      plan_id = raw_drugs.first[:plans].first[:plan_id]

      covered_drugs = raw_drugs.select do |drug|
        drug[:plans].any? { |plan| plan[:plan_id] == plan_id }
      end

      plan_drugs = repo.drugs_for_plan(OpenStruct.new(id: plan_id))
      expect(covered_drugs.length).to eq(plan_drugs.length)
      covered_drugs.each do |plan|
        rxnorm_code = plan[:rxnorm_id]
        matching_drugs = plan_drugs.select { |drug| drug.rxnorm_code == rxnorm_code }
        expect(matching_drugs.length).to eq(1)
      end
    end
  end
end
