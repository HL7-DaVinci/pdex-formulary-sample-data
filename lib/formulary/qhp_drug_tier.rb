# frozen_string_literal: true

require_relative 'qhp_drug_tier_cost_sharing'
module Formulary
  # An indivudual drug tier as represented by QHP data
  class QHPDrugTier
    attr_reader :tier

    def initialize(tier)
      @tier = tier
    end

    def name
      @name ||= tier[:drug_tier]
    end

    def mail_order?
      tier[:mail_order]
    end

    def cost_sharing
      @cost_sharing ||= tier[:cost_sharing].map { |cost| QHPDrugTierCostSharing.new(cost) }
    end
  end
end
