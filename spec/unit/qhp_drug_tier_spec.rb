# frozen_string_literal: true

require 'json'
require 'pry'
require_relative '../../lib/formulary/qhp_drug_tier'

RSpec.describe Formulary::QHPDrugTier do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_plans.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_plan) { raw_plans.first }

  let(:raw_tier) { raw_plan[:formulary].first }

  let(:tier) do
    Formulary::QHPDrugTier.new(raw_tier)
  end

  describe '.initialize' do
    it 'creates a QHPDrugTier instance' do
      expect(tier).to be_a(Formulary::QHPDrugTier)
    end
  end

  describe '#name' do
    it 'returns the tier name' do
      expect(tier.name).to eq('GENERIC')
    end
  end

  describe '#mail_order?' do
    it 'returns whether this is a mail order tier' do
      expect(tier.mail_order?).to be(true)
    end
  end

  describe '#cost_sharing' do
    it 'returns the tier cost sharing information' do
      expect(tier.cost_sharing).to eq(raw_tier[:cost_sharing])
    end
  end
end
