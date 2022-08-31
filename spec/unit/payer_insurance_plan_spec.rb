# frozen_string_literal: true

require_relative "../../lib/formulary/payer_insurance_plan_factory"
require_relative "../../lib/formulary/qhp_drug_tier"
require_relative "../../lib/formulary/qhp_plan"
require_relative "../../lib/formulary"

RSpec.describe Formulary::PayerInsurancePlanFactory do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, "..", "fixtures", "qhp_plans.json")
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_plan) { raw_plans.first }

  let(:plan) do
    Formulary::QHPPlan.new(raw_plan)
  end

  let(:id) { "#{Formulary::PAYER_PLAN_ID_PREFIX}#{plan.id}" }

  let(:factory) do
    Formulary::PayerInsurancePlanFactory.new(plan)
  end

  let(:resource) { factory.build }

  describe ".initialize" do
    it "creates a PayerInsurancePlanFactory instance" do
      expect(factory).to be_a(described_class)
    end
  end

  describe "#build" do
    it "creates a FHIR InsurancePlan resource" do
      expect(resource).to be_a(FHIR::InsurancePlan)
    end

    it "includes an id" do
      expect(resource.id).to eq(id)
    end

    it "includes the plan name" do
      names = plan.marketing_name.split(/\W+/)
      name = "#{names[0]} #{names[1]}"
      expect(resource.name).to eq(name)
      expect(resource.text.div).to include(name)
    end

    it "includes the date" do
      expect(resource.meta.lastUpdated).to include(plan.last_updated)
    end

    it "includes the Payer Insurance Plan profile" do
      expect(resource.meta.profile.first).to eq(Formulary::PAYER_INSURANCE_PLAN_PROFILE)
    end

    it "includes the marketing url" do
      expect(resource.contact.first.telecom.first.value).to eq(plan.marketing_url)
    end

    it "includes the email contact" do
      contact = resource.contact.find { |c| c.telecom.first.value == plan.email_contact }
      expect(contact).to be_truthy
    end

    it "includes a period" do
      expect(resource.period.start).to be_truthy
      expect(resource.period.end).to be_truthy
    end

    it "has a plan" do
      expect(resource.plan).not_to be_empty
    end

    it "has a coverage" do
      expect(resource.coverage).not_to be_empty
    end

    it "has a coverageArea" do
      expect(resource.coverageArea).not_to be_empty
    end
  end
end
