# frozen_string_literal: true

require "date"
require "fhir_models"
require_relative "../formulary"

module Formulary
  # Class to build Formulary resources from a QHPPlan
  class FormularyFactory
    attr_reader :plan

    def initialize(plan)
      @plan = plan
    end

    def build
      name.strip!

      FHIR::InsurancePlan.new(
        id: FORMULARY_ID_PREFIX + plan.id,
        meta: meta,
        text: text,
        identifier: identifier,
        status: "active",
        name: name,
        type: type,
        period: period,
      )
    end

    private

    def meta
      {
        profile: [FORMULARY_PROFILE],
        lastUpdated: plan.last_updated + "T00:00:00Z",
      }
    end

    def text
      {
        status: "generated",
        div: %(<div xmlns="http://www.w3.org/1999/xhtml">#{name}</div>),
      }
    end

    def identifier
      [{ value: FORMULARY_ID_PREFIX + plan.id }]
    end

    # @return the plan marketing name [String]
    def name
      plan.marketing_name
    end

    def type
      {
        coding: [
          {
            system: FORMULARY_LIST_CODE_SYSTEM,
            code: FORMULARY_LIST_CODE_CODE,
            display: FORMULARY_LIST_CODE_DISPLAY,
          },
        ],
      }
    end

    def period
      current_year = Date.today.year
      {
        "start": "#{current_year}-01-01",
        "end": "#{current_year}-12-31",
      }
    end
  end
end
