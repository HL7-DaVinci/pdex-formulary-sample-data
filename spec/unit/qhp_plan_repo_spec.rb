# frozen_string_literal: true

require 'json'
require 'pry'
require_relative '../../lib/formulary/qhp_plan_repo'

RSpec.describe Formulary::QHPPlanRepo do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_plans.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:repo) do
    Formulary::QHPPlanRepo
  end

  after(:each) do
    repo.reset!
  end

  describe '#import' do
    before(:each) { repo.import(raw_plans) }

    it 'stores plans' do
      plan_ids = raw_plans.map { |plan| plan[:plan_id] }

      expect(repo.all.length).to eq(plan_ids.length)
      plan_ids.each { |id| expect(repo.all.one? { |plan| plan.id == id }).to be(true) }
    end

    it 'converts the plans to QHPPlan' do
      repo.all.each { |plan| expect(plan).to be_a(Formulary::QHPPlan) }
    end
  end
end
