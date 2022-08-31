# frozen_string_literal: true

require_relative "../../lib/formulary/formulary_drug_factory"
require_relative "../../lib/formulary/qhp_plan_drug"
require_relative "../../lib/formulary/qhp_plan"
require_relative "../../lib/formulary/qhp_drug"

RSpec.describe Formulary::FormularyDrugFactory do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, "..", "fixtures", "qhp_plans.json")
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_drugs) do
    fixture_path = File.join(__dir__, "..", "fixtures", "qhp_drugs.json")
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

  describe ".initialize" do
    it "creates a FormularyDrugFactory instance" do
      expect(factory).to be_a(described_class)
    end
  end

  describe "#build" do
    it "creates a FHIR MedicationKnowledge resource" do
      expect(resource).to be_a(FHIR::MedicationKnowledge)
    end

    it "includes the rxnorm code" do
      expect(resource.code.coding.first.code).to eq(plan_drug.rxnorm_code)
    end

    it "includes the drug name" do
      expect(resource.code.coding.first.display).to eq(plan_drug.name)
    end

    it "includes the formulary profile" do
      expect(resource.meta.profile.first).to eq(Formulary::FORMULARY_DRUG_PROFILE)
    end

    it "includes the doseForm" do
      expect(resource).to respond_to(:doseForm)
    end
  end
end
