# frozen_string_literal: true

require_relative '../../lib/formulary/coverage_plan_factory'
require_relative '../../lib/formulary/qhp_drug_tier'

RSpec.describe Formulary::CoveragePlanFactory do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_plans.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_plan) { raw_plans.first }

  let(:plan) do
    Formulary::QHPPlan.new(raw_plan)
  end

  let(:tiers) do
    plan.tiers.map { |tier| Formulary::QHPDrugTier.new(tier) }
  end

  let(:factory) do
    Formulary::CoveragePlanFactory.new(plan)
  end

  let(:entries) do
    [
      {
        item: {
          reference: 'abc'
        }
      },
      {
        item: {
          reference: 'def'
        }
      }
    ]
  end

  let(:resource) { factory.build(entries) }

  describe '.initialize' do
    it 'creates a CoveragePlanFactory instance' do
      expect(factory).to be_a(Formulary::CoveragePlanFactory)
    end
  end

  describe '#build' do
    it 'creates a FHIR List resource' do
      expect(resource).to be_a(FHIR::List)
    end

    it 'includes the plan name' do
      expect(resource.title).to eq(plan.marketing_name)
      expect(resource.text.div).to include(plan.marketing_name)
    end

    it 'includes the date' do
      expect(resource.date).to eq(plan.last_updated)
    end

    it 'includes the coverage plan profile' do
      expect(resource.meta.profile.first).to eq(Formulary::COVERAGE_PLAN_PROFILE)
    end

    it 'includes a list of references' do
      list_entries = JSON.parse(resource.to_json, symbolize_names: true)[:entry]
      expect(list_entries).to eq(entries)
    end

    describe 'extensions' do
      let(:network_extensions) do
        resource.extension.select { |ext| ext.url == Formulary::NETWORK_EXTENSION }
      end

      %w[
        summary_url
        formulary_url
        marketing_url
        email_contact
        plan_id_type
        network
        drug_tier_definition
      ].each do |base_name|
        let("#{base_name}_extension".to_sym) do
          extension_url = Object.const_get("Formulary::#{base_name.upcase}_EXTENSION")
          resource.extension.select { |ext| ext.url == extension_url }
        end
      end

      it 'includes the network name' do
        networks = network_extension.map(&:valueString)

        expect(networks).to match_array(plan.network)
      end

      it 'includes the summary url' do
        expect(summary_url_extension.length).to eq(1)
        expect(summary_url_extension.first.valueString).to eq(plan.summary_url)
      end

      it 'includes the formulary url' do
        expect(formulary_url_extension.length).to eq(1)
        expect(formulary_url_extension.first.valueString).to eq(plan.formulary_url)
      end

      it 'includes the marketing url' do
        expect(marketing_url_extension.length).to eq(1)
        expect(marketing_url_extension.first.valueString).to eq(plan.marketing_url)
      end

      it 'includes the email contact' do
        expect(email_contact_extension.length).to eq(1)
        expect(email_contact_extension.first.valueString).to eq(plan.email_contact)
      end

      it 'includes the plan id type' do
        expect(plan_id_type_extension.length).to eq(1)
        expect(plan_id_type_extension.first.valueString).to eq(plan.id_type)
      end

      it 'includes the drug tiers' do
        expect(drug_tier_definition_extension.length).to eq(plan.tiers.length)
      end
    end
  end
end
