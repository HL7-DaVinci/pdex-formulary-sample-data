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
      expect(plan).to be_a(Formulary::QHPPlan)
    end
  end

  describe '#id' do
    it 'returns the plan id' do
      expect(plan.id).to eq('PLAN_ID_1')
    end
  end
end
