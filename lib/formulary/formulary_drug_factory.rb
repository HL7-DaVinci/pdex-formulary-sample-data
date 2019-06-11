# frozen_string_literal: true

require 'fhir_models'
require_relative '../formulary'

module Formulary
  # Class to build FormularyDrug resources from a QHPPlanDrug
  class FormularyDrugFactory
    attr_reader :plan_drug

    def initialize(plan_drug)
      @plan_drug = plan_drug
    end

    def build(id = nil)
      FHIR::MedicationKnowledge.new(
        id: id,
        code: code,
        extension: extension,
        text: text,
        meta: meta
      )
    end

    private

    def code
      {
        coding: [
          {
            system: RXNORM_SYSTEM,
            code: plan_drug.rxnorm_code,
            display: plan_drug.name
          }
        ]
      }
    end

    def extension
      [
        tier_extension,
        prior_auth_extension,
        step_therapy_extension,
        quantity_extension,
        plan_id_extension
      ]
    end

    def text
      {
        status: 'generated',
        div: '<div xmlns="http://www.w3.org/1999/xhtml"></div>'
      }
    end

    def meta
      { profile: [FORMULARY_PROFILE] }
    end

    def tier_extension # rubocop:disable Metrics/MethodLength
      {
        url: DRUG_TIER_EXTENSION,
        valueCodeableConcept: {
          coding: [
            {
              code: plan_drug.tier,
              display: plan_drug.tier,
              system: DRUG_TIER_SYSTEM
            }
          ]
        }
      }
    end

    def prior_auth_extension
      {
        url: PRIOR_AUTH_EXTENSION,
        valueBoolean: plan_drug.prior_auth?
      }
    end

    def step_therapy_extension
      {
        url: STEP_THERAPY_EXTENSION,
        valueBoolean: plan_drug.step_therapy_limit?
      }
    end

    def quantity_extension
      {
        url: QUANTITY_LIMIT_EXTENSION,
        valueBoolean: plan_drug.quantity_limit?
      }
    end

    def plan_id_extension
      {
        url: PLAN_ID_EXTENSION,
        valueString: plan_drug.plan_id
      }
    end
  end
end
