# frozen_string_literal: true

require_relative '../../lib/formulary/formulary_drug_factory'

RSpec.describe Formulary::FormularyDrugFactory do
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

  let(:factory) do
    Formulary::FormularyDrugFactory.new(plan_drug)
  end

  let(:resource) { factory.build }

  describe '.initialize' do
    it 'creates a FormularyDrugFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'creates a FHIR MedicationKnowledge resource' do
      expect(resource).to be_a(FHIR::MedicationKnowledge)
    end

    it 'includes the rxnorm code' do
      expect(resource.code.coding.first.code).to eq(plan_drug.rxnorm_code)
    end

    it 'includes the drug name' do
      expect(resource.code.coding.first.display).to eq(plan_drug.name)
    end

    it 'includes the formulary profile' do
      expect(resource.meta.profile.first).to eq(Formulary::FORMULARY_PROFILE)
    end

#    it 'includes the drug tier' do
#      tier_codings =
#        resource
#          .extension
#          .find { |extension| extension.url == Formulary::DRUG_TIER_EXTENSION }
#          .valueCodeableConcept
#          .coding
#      tier_code =
#        tier_codings
#          .find { |coding| coding.system == Formulary::DRUG_TIER_SYSTEM }
#          .code
#
#      expect(tier_code).to eq(plan_drug.tier)
#    end

#    it 'includes the prior auth requirement' do
#      prior_auth_required =
#        resource
#          .extension
#          .find { |extension| extension.url == Formulary::PRIOR_AUTH_EXTENSION }
#          .valueBoolean

#      expect(prior_auth_required).to eq(plan_drug.prior_auth?)
#    end

#    it 'includes the step therapy limit' do
#      step_therapy_limit =
#        resource
#          .extension
#          .find { |extension| extension.url == Formulary::STEP_THERAPY_EXTENSION }
#          .valueBoolean

#      expect(step_therapy_limit).to eq(plan_drug.step_therapy_limit?)
#    end

#    it 'includes the quantity limit' do
#      quantity_limit =
#        resource
#          .extension
#          .find { |extension| extension.url == Formulary::QUANTITY_LIMIT_EXTENSION }
#          .valueBoolean

#      expect(quantity_limit).to eq(plan_drug.quantity_limit?)
#    end

#    it 'includes the plan id' do
#      plan_id =
#        resource
#          .extension
#          .find { |extension| extension.url == Formulary::PLAN_ID_EXTENSION }
#          .valueString

#      expect(plan_id).to eq(plan_drug.plan_id)
#    end
  end
end
