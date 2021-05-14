# frozen_string_literal: true

module Formulary
  # A health plan as represented by QHP data
  class QHPPlan
    attr_reader :raw_plan

    def initialize(raw_plan)
      raw_plan[:formulary].map  { |tier| 

        if tier[:drug_tier] == "ZERO-COST-SHARE-PREVENTIVE"
          tier[:drug_tier] = "ZERO-COST-SHARE-PREVENTATIVE"
        end

       }
      @raw_plan = raw_plan.freeze
    end

    def id
      @id ||= raw_plan[:plan_id]
    end

    def marketing_name
      @marketing_name ||= raw_plan[:marketing_name]
    end

    def last_updated
      @last_updated ||= raw_plan[:last_updated_on]
    end

    def id_type
      @id_type ||= raw_plan[:plan_id_type]
    end

    def marketing_url
      @marketing_url ||= raw_plan[:marketing_url]
    end

    def email_contact
      @email_contact ||= raw_plan[:plan_contact]
    end

    def formulary_url
      @formulary_url ||= raw_plan[:formulary_url]
    end

    def summary_url
      @summary_url ||= raw_plan[:summary_url]
    end

    def network
      @network ||= raw_plan[:network].nil? ? nil : raw_plan[:network].map { |network| network[:network_tier] }
    end

    def tiers
      @tiers ||= raw_plan[:formulary]
    end
  end
end
