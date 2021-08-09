# frozen_string_literal: true

module Formulary
  # A drug with plan-specific details (tier, prior auth, limits)
  class QHPPlanDrug
    attr_reader :drug, :plan

    def initialize(drug, plan)
      @drug = drug
      @plan = plan
    end

    def rxnorm_code
      drug.rxnorm_code
    end

    def name
      drug.name
    end

    def tier

    if drug_plan_info[:drug_tier] == "ZERO-COST-SHARE-PREVENTIVE"
      drug_plan_info[:drug_tier] = "ZERO-COST-SHARE-PREVENTATIVE"
    elsif drug_plan_info[:drug_tier] == "MEDICAL-BENEFIT"
      drug_plan_info[:drug_tier] = "MEDICAL-SERVICE"
    elsif drug_plan_info[:drug_tier] == "NON-PREFERRED-BRAND-SPECIALTY"
      drug_plan_info[:drug_tier] = "SPECIALTY"
    end

      drug_plan_info[:drug_tier].downcase
 
    end

    def prior_auth?
      drug_plan_info[:prior_authorization]
    end

    def step_therapy_limit?
      drug_plan_info[:step_therapy]
    end

    def quantity_limit?
      drug_plan_info[:quantity_limit]
    end

    def plan_id
      plan.id
    end

    private

    def drug_plan_info
      @drug_plan_info ||= drug.plans.find { |drug_plan| drug_plan[:plan_id] == plan.id }
    end
  end
end
