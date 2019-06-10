module Formulary
  class QHPPlanDrug
    attr_reader :drug, :plan, :drug_plan_info

    def initialize(drug, plan)
      @drug = drug
      @plan = plan
    end

    def drug_plan_info
      @drug_plan_info ||= drug.plans.find { |drug_plan| drug_plan[:plan_id] == plan.id }
    end

    def rxnorm_code
      drug.rxnorm_code
    end

    def name
      drug.name
    end

    def tier
      drug_plan_info[:drug_tier]
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
  end
end
