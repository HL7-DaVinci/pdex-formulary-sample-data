# frozen_string_literal: true

require 'fhir_models'
require_relative '../formulary'

module Formulary
  # Class to build FormularyDrug resources from a QHPPlanDrug
  class FormularyItemFactory
    attr_reader :plan, :plan_drug

    def initialize(plan, plan_drug)
      @plan = plan
      @plan_drug = plan_drug
    end

    def build()
      FHIR::Basic.new(
        id: FORMULARY_ITEM_ID_PREFIX + plan.id + "-" + plan_drug.rxnorm_code,
        meta: meta,
        text: text,
        extension: extension,
        code: code,
        subject: subject
        
      )
    end

    private

    def meta
      {
        profile: [FORMULARY_ITEM_PROFILE],
        lastUpdated: '2021-08-31T10:03:10Z'
      }
    end

    def text
      {
        status: 'generated',
        #div: '<div xmlns="http://www.w3.org/1999/xhtml"></div>'
        #div: %(<div xmlns="http://www.w3.org/1999/xhtml">Formulary Item for #{plan_drug.name}</div>)
        div: "<div xmlns=\"http://www.w3.org/1999/xhtml\">Formulary Item for Plan: #{plan.id}; RxNorm: #{plan_drug.rxnorm_code}</div>"
      }
    end

    
    def extension
      [
        drug_plan_reference_extension,
        availability_status_extension,
        availability_period_extension,
        pharmacy_type_extension,  # HOW TO ADDRESS Pharmacy Type. It is not part of the QHP Drugs
        drug_tier_extension,
        prior_auth_extension,
        prior_auth_new_start_extension,
        step_therapy_extension,
        step_therapy_new_start_extension,
        quantity_limit_extension
        # TODO Qunatity limit details
        #quantity_limit_detail_extension
      ]
    end

    
    def code
      {
        coding: [
          {
            system: FORMULARY_ITEM_SYSTEM,
            code: 'formulary-item',
            display: 'Formulary Item'
          }
        ]
      }
    end

    def subject
      {
        reference: 'MedicationKnowledge/' + DRUG_ID_PREFIX + plan_drug.rxnorm_code,
        type: 'MedicationKnowledge'
      }
    end
    

    def drug_plan_reference_extension
      {
        url: DRUG_PLAN_REFERENCE_EXTENSION,
        valueReference: {
            reference: 'InsurancePlan/' + DRUG_PLAN_ID_PREFIX + plan.id,
            type: 'InsurancePlan'   
        }
      }
    end

    def availability_status_extension
      {
        url: AVAILABILITY_STATUS_EXTENSION,
        valueCode: 'active'
      }
    end

    def availability_period_extension
      {
        url: AVAILABILITY_PERIOD_EXTENSION,
        valuePeriod: {
            start: '2021-01-01',
            end: '2021-12-31'
        }
      }
    end
    


    #AVAILABILITY_STATUS_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-AvailabilityStatus-extension'
    #AVAILABILITY_PERIOD_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-AvailabilityPeriod-extension'
    #PHARMACY_TYPE_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PharmacyType-extension'
    #DRUG_TIER_ID_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-DrugTierID-extension'
    #PRIOR_AUTH_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PriorAuthorizationNewStartsOnly-extension'
    #PRIOR_AUTH_NEW_START_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PriorAuthorizationNewStartsOnly-extension'
    #STEP_THERAPY_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-StepTherapyLimit-extension'
    #STEP_THERAPY_NEW_START_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-StepTherapyLimitNewStartsOnly-extension'
    #QUANTITY_LIMIT_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-QuantityLimit-extension'
    #QUANTITY_LIMIT_DETAIL_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-QuantityLimitDetail-extension'
    #QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION = 'Rolling'
    #QUANTITY_LIMIT_DETAIL_MAXIMUM_DAILY_EXTENSION = 'MaximumDaily'
    #QUANTITY_LIMIT_DETAIL_DAYS_SUPPLY_EXTENSION = 'DaysSupply'




    def pharmacy_type_extension
      value = '1-month-in-retail'
      {
        url: PHARMACY_TYPE_EXTENSION,
        valueCodeableConcept: {
          coding: [
            {
              code: value,
              display: PHARMACY_TYPE_DISPLAY[value],
              system: PHARMACY_TYPE_SYSTEM
            }
          ]
        }
      }
    end


    
    def drug_tier_extension # rubocop:disable Metrics/MethodLength
      {
        url: DRUG_TIER_ID_EXTENSION,
        valueCodeableConcept: {
          coding: [
            {
              code: plan_drug.tier,
              display: DRUG_TIER_DISPLAY[plan_drug.tier],
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

    def prior_auth_new_start_extension
      if plan_drug.prior_auth? 
        # Compute a number to get a new start only value related to this formulary item
        compnumber =  plan_drug.rxnorm_code.tr('^0-9', '') + plan.id.tr('^0-9', '')#.to_i.digits.sum.to_s
        while compnumber.length > 1
          compnumber = compnumber.to_i.digits.sum.to_s
        end
        compnumber = compnumber.to_i % 2

        {
          url: PRIOR_AUTH_NEW_START_EXTENSION,
          valueBoolean: compnumber.zero?
        }

      end
    end

    def step_therapy_extension
      {
        url: STEP_THERAPY_EXTENSION,
        valueBoolean: plan_drug.step_therapy_limit?
      }
    end


    def step_therapy_new_start_extension
      if plan_drug.step_therapy_limit? 
        # Compute a number to get a new start only value related to this formulary item
        compnumber =  plan_drug.rxnorm_code.tr('^0-5', '') + plan.id.tr('^0-5', '')#.to_i.digits.sum.to_s
        while compnumber.length > 1
          compnumber = compnumber.to_i.digits.sum.to_s
        end
        compnumber = compnumber.to_i % 2
        {
          url: STEP_THERAPY_NEW_START_EXTENSION,
          valueBoolean: compnumber.zero?
        }
      end
    end

    def quantity_limit_extension
      {
        url: QUANTITY_LIMIT_EXTENSION,
        valueBoolean: plan_drug.quantity_limit?
      }
    end

    
  end
end
