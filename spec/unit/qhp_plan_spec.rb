# frozen_string_literal: true

require 'json'
require 'pry'
require_relative '../../lib/formulary/qhp_plan'

RSpec.describe Formulary::QHPPlan do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_plans.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_plan) { raw_plans.first }

  let(:plan) do
    Formulary::QHPPlan.new(raw_plan)
  end

  describe '.initialize' do
    it 'creates a QHPPlan instance' do
      expect(plan).to be_a(described_class)
    end
  end

  describe '#id' do
    it 'returns the plan id' do
      expect(plan.id).to eq('PLAN_ID_1')
    end
  end

  describe '#marketing_name' do
    it 'returns the plan marketing name' do
      expect(plan.marketing_name).to eq('MARKETING_NAME_1')
    end
  end

  describe '#last_updated' do
    it 'returns the last update date for the plan' do
      expect(plan.last_updated).to eq('2019-06-10')
    end
  end

  describe '#id_type' do
    it 'returns the plan id type' do
      expect(plan.id_type).to eq('HIOS-PLAN-ID')
    end
  end

  describe '#marketing_url' do
    it 'returns the plan marketing url' do
      expect(plan.marketing_url).to eq('http://example.com/marketing')
    end
  end

  describe '#email_contact' do
    it 'returns the plan email contact' do
      expect(plan.email_contact).to eq('contact1@example.com')
    end
  end

  describe '#formulary_url' do
    it 'returns the plan formulary url' do
      expect(plan.formulary_url).to eq('http://example.com/formulary')
    end
  end

  describe '#summary_url' do
    it 'returns the plan summary url' do
      expect(plan.summary_url).to eq('http://example.com/summary')
    end
  end

  describe '#network' do
    it 'returns the plan network' do
      expect(plan.network).to eq(['PREFERRED'])
    end
  end

  describe '#tiers' do
    it 'returns the plan tiers' do
      expect(plan.tiers).to eq(raw_plan[:formulary])
    end
  end
end
