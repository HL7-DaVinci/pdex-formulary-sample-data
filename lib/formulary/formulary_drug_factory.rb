# frozen_string_literal: true

require "fhir_models"
require_relative "../formulary"

module Formulary
  # Class to build FormularyDrug resources from a QHPPlanDrug
  class FormularyDrugFactory
    attr_reader :plan_drug

    def initialize(plan_drug)
      @plan_drug = plan_drug
    end

    def build(id = nil)
      FHIR::MedicationKnowledge.new(
        id: DRUG_ID_PREFIX + id,
        code: code,
        status: "active",
        doseForm: dose_form,
        # TODO Need to do related Medication Knowledge (possibly optional based on testing outcomes)
        # Can we add classigfication for testing? Will need to build out source data more.
        meta: meta,
      )
    end

    private

    def code
      {
        coding: [
          {
            system: RXNORM_SYSTEM,
            code: plan_drug.rxnorm_code,
            display: plan_drug.name,
          },
        ],
      }
    end

    def dose_form
      json_data = File.read("doseform.json")
      dose_forms = JSON.parse(json_data, :symbolize_names => true)
      coding = dose_forms.find { |coding| plan_drug.name.downcase.include?(coding[:display].downcase) }
      return if coding.nil?
      {
        coding: [coding],
      }
    end

    def text
      {
        status: "generated",
        #div: '<div xmlns="http://www.w3.org/1999/xhtml"></div>'
        div: %(<div xmlns="http://www.w3.org/1999/xhtml">#{plan_drug.name}</div>),
      }
    end

    def meta
      {
        profile: [FORMULARY_DRUG_PROFILE],
        lastUpdated: "2021-08-31T10:03:10Z",
      }
    end
  end
end
