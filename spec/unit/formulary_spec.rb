# frozen_string_literal: true

require_relative "../../lib/formulary/formulary_factory"
require_relative "../../lib/formulary/qhp_plan"
require_relative "../../lib/formulary"

RSpec.describe Formulary::FormularyFactory do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, "..", "fixtures", "qhp_plans.json")
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_plan) { raw_plans.first }

  let(:plan) do
    Formulary::QHPPlan.new(raw_plan)
  end

  let(:id) { "#{Formulary::FORMULARY_ID_PREFIX}#{plan.id}" }

  let(:factory) do
    Formulary::FormularyFactory.new(plan)
  end

  let(:resource) { factory.build }

  describe ".initialize" do
    it "creates a FormularyFactory instance" do
      expect(factory).to be_a(described_class)
    end
  end

  describe "#build" do
    it "creates a FHIR InsurancePlan resource" do
      expect(resource).to be_a(FHIR::InsurancePlan)
    end

    it "creates a FHIR InsurancePlan resource with an id" do
      expect(resource.id).to eq(id)
    end

    it "creates a FHIR InsurancePlan resource with a plan name" do
      expect(resource.name).to eq(plan.marketing_name)
      expect(resource.text.div).to include(plan.marketing_name)
    end

    it "creates a FHIR InsurancePlan resource with a date in meta.lastUpdated" do
      expect(resource.meta.lastUpdated).to include(plan.last_updated)
    end

    it "includes the Payer Insurance Plan profile" do
      expect(resource.meta.profile.first).to eq(Formulary::FORMULARY_PROFILE)
    end

    it "creates a FHIR InsurancePlan resource with a status" do
      expect(resource.status).to be_truthy
    end

    it "creates a FHIR InsurancePlan resource with a period field" do
      expect(resource).to respond_to(:period)
      expect(resource.period).to respond_to(:start)
      expect(resource.period).to respond_to(:end)
    end
    it "creates a FHIR InsurancePlan resource with a type" do
      expect(resource).to respond_to(:type)
    end

    describe "FHIR::InsurancePlan#type.coding" do
      let(:coding) { resource.type.first.coding.first }
      it "has a system field" do
        expect(coding.system).to eq(Formulary::FORMULARY_TYPE_SYSTEM)
        expect(coding.code).to eq (Formulary::FORMULARY_TYPE_CS_CODE)
      end
    end
  end
end
