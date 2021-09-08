# frozen_string_literal: true

require_relative '../../lib/formulary/payer_insurance_plan_factory'
require_relative '../../lib/formulary/qhp_drug_tier'

RSpec.describe Formulary::PayerInsurancePlanFactory do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_plans.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_plan) { raw_plans.first }

  let(:plan) do
    Formulary::QHPPlan.new(raw_plan)
  end

  let(:id) { 'PLAN_ID' }

  let(:factory) do
    Formulary::PayerInsurancePlanFactory.new(plan, id)
  end

  describe '.initialize' do
    it 'creates a PayerInsurancePlanFactory instance' do
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
        names = plan.marketing_name.split(/\W+/)
        name = names[0] + ' ' + names[1]
      expect(resource.name).to eq(name)
      expect(resource.text.div).to include(name)
    end

    it 'includes the date' do
      expect(resource.meta.lastUpdated).to eq(plan.last_updated)
    end

    it 'includes the Payer Insurance Plan profile' do
      expect(resource.meta.profile.first).to eq(Formulary::PAYER_INSURANCE_PLAN_PROFILE)
    end

    it 'includes the marketing url' do
        expect(resource.contact.telecom.first.value).to eq(plan.marketing_url)
    end

    it 'includes the email contact' do
        expect(resource.contact.telecom.second.value).to eq(plan.email_contact)
    end

    describe 'extensions' do

      %w[
        drug_plan_extension
      ].each do |base_name|
        let("#{base_name}_extension".to_sym) do
          extension_url = Object.const_get("Formulary::#{base_name.upcase}_EXTENSION")
          resource.extension.select { |ext| ext.url == extension_url }
        end
      end

      it 'includes the drug plan reference' do
        expect(marketing_url_extension.length).to eq(1)
        expect(drug_plan_extension.valueReference.reference).to eq('InsurancePlan/Drug' + plan.id)
      end

      
    end
  end
end
