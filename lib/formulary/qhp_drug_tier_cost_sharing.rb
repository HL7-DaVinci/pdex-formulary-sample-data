# frozen_string_literal: true

module Formulary
  # Cost sharing information for a drug tier as represented by QHP data
  class QHPDrugTierCostSharing
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def copay_option
      option_with_default_value(data[:copay_opt], copay_amount).nil? ? nil : option_with_default_value(data[:copay_opt], copay_amount).downcase
    end

    def coinsurance_option
      option_with_default_value(data[:coinsurance_opt], coinsurance_rate).nil? ? nil :option_with_default_value(data[:coinsurance_opt], coinsurance_rate).downcase
    end

    def pharmacy_type
      data[:pharmacy_type].nil? ? nil : data[:pharmacy_type].downcase
    end

    def copay_amount
      data[:copay_amount]
    end

    def coinsurance_rate
      data[:coinsurance_rate]
    end

    private

    def option_with_default_value(option, rate)
      return option # unless option.nil?

      # rate.positive? ? 'AFTER-DEDUCTIBLE' : 'NO-CHARGE'
    end
  end
end
