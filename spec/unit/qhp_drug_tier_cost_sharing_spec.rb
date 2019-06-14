# frozen_string_literal: true

RSpec.describe Formulary::QHPDrugTierCostSharing do
  let(:raw_cost_sharing) do
    {
      pharmacy_type: '1-MONTH-IN-RETAIL',
      copay_amount: 0,
      copay_opt: 'BEFORE-DEDUCTIBLE',
      coinsurance_rate: 0,
      coinsurance_opt: 'NO-CHARGE-AFTER-DEDUCTIBLE'
    }
  end

  let(:cost_sharing) { Formulary::QHPDrugTierCostSharing.new(raw_cost_sharing) }

  describe '.initialize' do
    it 'creates a QHPDrugTierCostSharing instance' do
      expect(cost_sharing).to be_a(described_class)
    end
  end

  describe '#pharmacy_type' do
    it 'returns the pharmacy type' do
      expect(cost_sharing.pharmacy_type).to eq(raw_cost_sharing[:pharmacy_type])
    end
  end

  describe '#copay_amount' do
    it 'returns the copay amount' do
      expect(cost_sharing.copay_amount).to eq(raw_cost_sharing[:copay_amount])
    end
  end

  describe '#coinsurance_rate' do
    it 'returns the coinsurance rate' do
      expect(cost_sharing.coinsurance_rate).to eq(raw_cost_sharing[:coinsurance_rate])
    end
  end
  describe '#copay_option' do
    it 'returns the copay option' do
      expect(cost_sharing.copay_option).to eq(raw_cost_sharing[:copay_opt])
    end

    context 'when the copay_option is null' do
      it 'returns NO-CHARGE if the copay amount is zero' do
        no_copay_option = Formulary::QHPDrugTierCostSharing.new(
          copay_amount: 0,
          copay_opt: nil
        )

        expect(no_copay_option.copay_option).to eq('NO-CHARGE')
      end

      it 'returns AFTER-DEDUCTIBLE if the copay amount is greater than zero' do
        no_copay_option = Formulary::QHPDrugTierCostSharing.new(
          copay_amount: 10,
          copay_opt: nil
        )

        expect(no_copay_option.copay_option).to eq('AFTER-DEDUCTIBLE')
      end
    end
  end

  describe '#coinsurance_option' do
    it 'returns the coinsurance option' do
      expect(cost_sharing.coinsurance_option).to eq(raw_cost_sharing[:coinsurance_opt])
    end

    context 'when the coinsurance_option is null' do
      it 'returns NO-CHARGE if the coinsurance rate is zero' do
        no_coins_option = Formulary::QHPDrugTierCostSharing.new(
          coinsurance_rate: 0,
          coinsurance_opt: nil
        )

        expect(no_coins_option.coinsurance_option).to eq('NO-CHARGE')
      end

      it 'returns AFTER-DEDUCTIBLE if the coinsurance amount is greater than zero' do
        no_coins_option = Formulary::QHPDrugTierCostSharing.new(
          coinsurance_rate: 0.1,
          coinsurance_opt: nil
        )

        expect(no_coins_option.coinsurance_option).to eq('AFTER-DEDUCTIBLE')
      end
    end
  end
end
