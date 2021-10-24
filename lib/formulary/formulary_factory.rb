# frozen_string_literal: true

require 'fhir_models'
require_relative '../formulary'
require_relative 'qhp_drug_tier'
require_relative 'qhp_drug_tier_cost_sharing'
require_relative 'drug_tier_extension_factory'


# TODO DRUG Tiers pharmacy tiers

module Formulary
  # Class to build Formulary resources from a QHPPlan
  class FormularyFactory # rubocop:disable Metrics/ClassLength
    attr_reader :plan, :id

    def initialize(plan, id)
      @plan = plan
      @id = id
    end

    def build(entries) # rubocop:disable Metrics/MethodLength
      name.strip!
      
      FHIR::InsurancePlan.new(
        #id: id,
        id: FORMULARY_ID_PREFIX + plan.id,
        meta: meta,
        text: text,
        identifier: identifier,
        status: 'active',
        name: name,
        type: type
        #contact: contact,
        #plan: plans
      )
    end

    private

    def meta
        {
          profile: [FORMULARY_PROFILE],
          lastUpdated: plan.last_updated + "T00:00:00Z"
        }
    end

    def text
        {
          status: 'generated',
          div: %(<div xmlns="http://www.w3.org/1999/xhtml">#{name}</div>)
        }
    end

    def identifier
      [{ value: FORMULARY_ID_PREFIX + plan.id }]
    end

    def name
        plan.marketing_name
    end

    def type
      {
        coding: [
          {
            system: FORMULARY_LIST_CODE_SYSTEM,
            code: FORMULARY_LIST_CODE_CODE,
            display: FORMULARY_LIST_CODE_DISPLAY
          }
        ]
      }
    end


    #def benefit_costs(value)
    #    value.map { |cost| specific_cost_benefit(cost)}
    #end
  end
end
