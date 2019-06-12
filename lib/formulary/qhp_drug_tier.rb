# frozen_string_literal: true

module Formulary
  # An indivudual drug tier as represented by QHP data
  class QHPDrugTier
    attr_reader :tier

    def initialize(tier)
      @tier = tier
    end

    def name
      tier[:drug_tier]
    end

    def mail_order?
      tier[:mail_order]
    end

    def cost_sharing
      tier[:cost_sharing]
    end
  end
end
