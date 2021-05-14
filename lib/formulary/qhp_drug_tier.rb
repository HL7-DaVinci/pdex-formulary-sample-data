# frozen_string_literal: true

require_relative 'qhp_drug_tier_cost_sharing'
module Formulary
  # An individual drug tier as represented by QHP data
  class QHPDrugTier
    attr_reader :tier

    def initialize(tier)
      @tier = tier
      if tier[:drug_tier] == "ZERO-COST-SHARE-PREVENTIVE"
        tier[:drug_tier] = "ZERO-COST-SHARE-PREVENTATIVE"
      end
    end

    def name
      @name ||= tier[:drug_tier].nil? ? nil : tier[:drug_tier].downcase
    end

    def mail_order?
      tier[:mail_order]
    end

    def cost_sharing
      @cost_sharing ||= tier[:cost_sharing].map { |cost| QHPDrugTierCostSharing.new(cost) }
    end
  end
end
