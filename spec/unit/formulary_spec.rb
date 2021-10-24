# frozen_string_literal: true

require_relative '../../lib/formulary/formulary_factory'
require_relative '../../lib/formulary/qhp_drug_tier'

RSpec.describe Formulary::FormularyFactory do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_plans.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_plan) { raw_plans.first }

  let(:plan) do
    Formulary::QHPPlan.new(raw_plan)
  end

  #let(:tiers) do
  #  plan.tiers.map { |tier| Formulary::QHPDrugTier.new(tier) }
  #end

  let(:id) { 'PLAN_ID' }

  let(:factory) do
    Formulary::FormularyFactory.new(plan, id)
  end

  describe '.initialize' do
    it 'creates a FormularyFactory instance' do
      expect(factory).to be_a(described_class)
    end
  end

  describe '#build' do
    it 'creates a FHIR InsurancePlan resource' do
      expect(resource).to be_a(FHIR::InsurancePlan)
    end

    it 'includes an id' do
      expect(resource.id).to eq(id)
    end

    it 'includes the plan name' do
      expect(resource.name).to eq(plan.marketing_name)
      expect(resource.text.div).to include(plan.marketing_name)
    end

    it 'includes the date' do
      expect(resource.meta.lastUpdated).to eq(plan.last_updated)
    end

    it 'includes the Payer Insurance Plan profile' do
      expect(resource.meta.profile.first).to eq(Formulary::FORMULARY_PROFILE)
    end

    it 'includes the marketing url' do
        expect(resource.contact.telecom.first.value).to eq(plan.marketing_url)
    end

    it 'includes the email contact' do
        expect(resource.contact.telecom.second.value).to eq(plan.email_contact)
    end

    describe 'extensions' do

      %w[
        formulary_extension
      ].each do |base_name|
        let("#{base_name}_extension".to_sym) do
          extension_url = Object.const_get("Formulary::#{base_name.upcase}_EXTENSION")
          resource.extension.select { |ext| ext.url == extension_url }
        end
      end
    end
  end
end
