module Formulary
  class QHPDrug
    attr_reader :raw_data

    def initialize(raw_data)
      @raw_data = raw_data.freeze
    end

    def rxnorm_code
      raw_data[:rxnorm_id]
    end

    def name
      raw_data[:drug_name]
    end

    def plans
      raw_data[:plans]
    end
  end
end
