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

      it 'includes an id for each drug tier' do
        input_tier_ids = tiers.map(&:name)
        output_tier_ids = drug_tier_definition_extension.map do |tier_extension|
          id_extension = tier_extension.extension.find do |extension|
            extension.url == Formulary::DRUG_TIER_ID_EXTENSION
          end
          id_extension.valueCodeableConcept.coding.first.code
        end

        expect(output_tier_ids).to match_array(input_tier_ids)
      end

      it 'includes mail order info for each drug tier' do
        input_tier_mail_order = tiers.map(&:mail_order?)
        output_tier_mail_order = drug_tier_definition_extension.map do |tier_extension|
          mail_order_extension = tier_extension.extension.find do |extension|
            extension.url == Formulary::MAIL_ORDER_EXTENSION
          end
          mail_order_extension.valueBoolean
        end

        expect(output_tier_mail_order).to match_array(input_tier_mail_order)
      end

      it 'includes cost sharing info for each drug tier' do
        input_cost_sharing = tiers.map(&:cost_sharing)
        output_cost_sharing = drug_tier_definition_extension.map do |tier_extension|
          tier_extension.extension.select { |ext| ext.url == Formulary::COST_SHARING_EXTENSION }
        end

        expect(input_cost_sharing.length).to eq(output_cost_sharing.length)
        input_cost_sharing.zip(output_cost_sharing).each do |cost_sharing|
          input_length = cost_sharing.first.length
          output_length = cost_sharing.last.length
          expect(output_length).to eq(input_length)
        end
      end

      it 'includes cost sharing details' do
        output_cost_sharing =
          drug_tier_definition_extension.first.extension
                                        .find { |ext| ext.url == Formulary::COST_SHARING_EXTENSION }

        expected_extension_urls = [
          Formulary::PHARMACY_TYPE_EXTENSION,
          Formulary::COPAY_AMOUNT_EXTENSION,
          Formulary::COINSURANCE_RATE_EXTENSION,
          Formulary::COINSURANCE_OPTION_EXTENSION,
          Formulary::COPAY_OPTION_EXTENSION
        ]

        actual_extension_urls = output_cost_sharing.extension.map(&:url)
        expect(actual_extension_urls).to match_array(expected_extension_urls)
      end
    end
  end
end
