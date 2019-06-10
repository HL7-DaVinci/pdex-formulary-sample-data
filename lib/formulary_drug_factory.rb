require 'fhir_models'

module Formulary
  class FormularyDrugFactory
    attr_reader :plan_drug

    def initialize(plan_drug)
      @plan_drug = plan_drug
    end

    def build
      FHIR::MedicationKnowledge.new(
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
            system: 'http://www.nlm.nih.gov/research/umls/rxnorm',
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
      {
        profile: [
          'http://hl7.org/fhir/us/Davinci-drug-formulary/StructureDefinition/usdf-FormularyDrug'
        ]
      }
    end

    def tier_extension
      {
        url: 'http://hl7.org/fhir/us/Davinci-drug-formulary/StructureDefinition/usdf-DrugTierID-extension',
        valueCodeableConcept: {
          coding: [
            {
              code: plan_drug.tier,
              display: plan_drug.tier,
              system: 'http://hl7.org/fhir/us/Davinci-drug-formulary/CodeSystem/usdf-DrugTierCS'
            }
          ]
        }
      }
    end

    def prior_auth_extension
      {
        url: 'http://hl7.org/fhir/us/Davinci-drug-formulary/StructureDefinition/usdf-PriorAuthorization-extension',
        valueBoolean: plan_drug.prior_auth?
      }
    end

    def step_therapy_extension
      {
        url: 'http://hl7.org/fhir/us/Davinci-drug-formulary/StructureDefinition/usdf-StepTherapyLimit-extension',
        valueBoolean: plan_drug.step_therapy_limit?
      }
    end

    def quantity_extension
      {
        url: 'http://hl7.org/fhir/us/Davinci-drug-formulary/StructureDefinition/usdf-QuantityLimit-extension',
        valueBoolean: plan_drug.quantity_limit?
      }
    end

    def plan_id_extension
      {
        url: 'http://hl7.org/fhir/us/Davinci-drug-formulary/StructureDefinition/usdf-PlanID-extension',
        valueString: plan_drug.plan_id
      }
    end
  end
end
