# frozen_string_literal: true

require 'json'
require 'pry'
require_relative '../../lib/formulary/qhp_plan_drug'

RSpec.describe Formulary::QHPPlanDrug do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_plans.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_drugs) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_drugs.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_plan) { raw_plans.first }

  let(:raw_drug) { raw_drugs.first }

  let(:plan) do
    Formulary::QHPPlan.new(raw_plan)
  end

  let(:drug) do
    Formulary::QHPDrug.new(raw_drug)
  end

  let(:plan_drug) do
    Formulary::QHPPlanDrug.new(drug, plan)
  end

  describe '.initialize' do
    it 'creates a QHPPlanDrug instance' do
      expect(plan_drug).to be_a(described_class)
    end
  end

  describe '#rxnorm_code' do
    it 'returns the rxnorm code for the drug' do
      expect(plan_drug.rxnorm_code).to eq('RXNORM_ID_1')
    end
  end

  describe '#name' do
    it 'returns the drug name' do
      expect(plan_drug.name).to eq('DRUG_NAME_1')
    end
  end

  describe '#tier' do
    it 'returns the drug tier' do
      expect(plan_drug.tier).to eq('generic')
    end
  end

  describe '#prior_auth?' do
    it 'returns whether this drug requires prior auth under this plan' do
      expect(plan_drug.prior_auth?).to be(true)
    end
  end

  describe '#step_therapy_limit?' do
    it 'returns whether this drug has a step therapy limit under this plan' do
      expect(plan_drug.step_therapy_limit?).to be(true)
    end
  end

  describe '#quantity_limit?' do
    it 'returns whether this drug has a quantity limit under this plan' do
      expect(plan_drug.quantity_limit?).to be(true)
    end
  end

  describe '#plan_id' do
    it 'returns the plan id' do
      expect(plan_drug.plan_id).to eq('PLAN_ID_1')
    end
  end
end
