# frozen_string_literal: true

require_relative '../../lib/formulary/drug_tier_extension_factory'

RSpec.describe Formulary::DrugTierExtensionFactory do
  let(:tier) do
    OpenStruct.new(
      name: 'DRUG_TIER',
      'mail_order?'.to_sym => true,
      cost_sharing: [
        {
          pharmacy_type: '1-MONTH-IN-RETAIL',
          copay_amount: 70.0,
          copay_opt: 'AFTER-DEDUCTIBLE',
          coinsurance_rate: 1.0,
          coinsurance_opt: 'AFTER-DEDUCTIBLE'
        },
        {
          pharmacy_type: '3-MONTH-IN-RETAIL',
          copay_amount: 140.0,
          copay_opt: 'AFTER-DEDUCTIBLE',
          coinsurance_rate: 1.0,
          coinsurance_opt: 'AFTER-DEDUCTIBLE'
        }
      ]
    )
  end

  let(:factory) { Formulary::DrugTierExtensionFactory.new(tier) }

  let(:tier_extension) { factory.build }

  let(:cost_sharing_extensions) do
    tier_extension
      .extension
      .select { |ext| ext.url == Formulary::COST_SHARING_EXTENSION }
  end

  describe 'initialize' do
    it 'creates a DrugTierExtensionFactory instance' do
      expect(factory).to be_a(Formulary::DrugTierExtensionFactory)
    end
  end

  describe 'build' do
    it 'includes an id' do
      id_extension = tier_extension.extension.find do |extension|
        extension.url == Formulary::DRUG_TIER_ID_EXTENSION
      end
      id = id_extension.valueCodeableConcept.coding.first.code

      expect(id).to eq(tier.name)
    end

    it 'includes mail order info' do
      mail_order_extension = tier_extension.extension.find do |extension|
        extension.url == Formulary::MAIL_ORDER_EXTENSION
      end

      expect(mail_order_extension.valueBoolean).to eq(tier.mail_order?)
    end

    it 'includes cost sharing info' do
      output_cost_sharing =
        cost_sharing_extensions
          .select { |ext| ext.url == Formulary::COST_SHARING_EXTENSION }

      expect(output_cost_sharing.length).to eq(tier.cost_sharing.length)
    end

    it 'includes the pharmacy type for each cost sharing extension' do
      input_pharmacy_types = tier.cost_sharing.map { |cost| cost[:pharmacy_type] }
      output_pharmacy_types =
        cost_sharing_extensions
          .flat_map(&:extension)
          .select { |ext| ext.url == Formulary::PHARMACY_TYPE_EXTENSION }
          .map { |ext| ext.valueCodeableConcept.coding.first.code }

      expect(output_pharmacy_types).to match_array(input_pharmacy_types)
    end

    it 'includes the copay amount for each cost sharing extension' do
      input_copay_amount = tier.cost_sharing.map { |cost| cost[:copay_amount] }
      output_copay_amount =
        cost_sharing_extensions
          .select { |ext| ext.url == Formulary::COST_SHARING_EXTENSION }
          .flat_map(&:extension)
          .select { |ext| ext.url == Formulary::COPAY_AMOUNT_EXTENSION }
          .map { |ext| ext.valueMoney.value }

      expect(output_copay_amount).to match_array(input_copay_amount)
    end

    it 'includes the copay option for each cost sharing extension' do
      input_copay_option = tier.cost_sharing.map { |cost| cost[:copay_opt] }
      output_copay_option =
        cost_sharing_extensions
          .select { |ext| ext.url == Formulary::COST_SHARING_EXTENSION }
          .flat_map(&:extension)
          .select { |ext| ext.url == Formulary::COPAY_OPTION_EXTENSION }
          .map { |ext| ext.valueCodeableConcept.coding.first.code }

      expect(output_copay_option).to match_array(input_copay_option)
    end

    it 'includes the coinsurance rate for each cost sharing extension' do
      input_coinsurance_rate = tier.cost_sharing.map { |cost| cost[:coinsurance_rate] }
      output_coinsurance_rate =
        cost_sharing_extensions
          .select { |ext| ext.url == Formulary::COST_SHARING_EXTENSION }
          .flat_map(&:extension)
          .select { |ext| ext.url == Formulary::COINSURANCE_RATE_EXTENSION }
          .map(&:valueDecimal)

      expect(output_coinsurance_rate).to match_array(input_coinsurance_rate)
    end

    it 'includes the coinsurance option for each cost sharing extension' do
      input_coinsurance_option = tier.cost_sharing.map { |cost| cost[:coinsurance_opt] }
      output_coinsurance_option =
        cost_sharing_extensions
          .select { |ext| ext.url == Formulary::COST_SHARING_EXTENSION }
          .flat_map(&:extension)
          .select { |ext| ext.url == Formulary::COINSURANCE_OPTION_EXTENSION }
          .map { |ext| ext.valueCodeableConcept.coding.first.code }

      expect(output_coinsurance_option).to match_array(input_coinsurance_option)
    end
  end
end
