# frozen_string_literal: true

require 'fhir_models'
require_relative '../formulary'


module Formulary
  # Class to build PayerInsurancePlan resources from a QHPPlan
  class PayerInsurancePlanFactory # rubocop:disable Metrics/ClassLength
    attr_reader :plan, :id

    def initialize(plan, id)
      @plan = plan
      @id = id
    end

    def build(entries) # rubocop:disable Metrics/MethodLength
      name.strip!

      FHIR::InsurancePlan.new(
        #id: id,
        id: PAYER_PLAN_ID_PREFIX + plan.id,
        meta: meta,
        text: text,
        extension: extension,
        identifier: identifier,
        status: 'active',
        name: name,
        type: type,
        contact: contact
        
      )
    end

    private

    def meta
        {
          profile: [PAYER_INSURANCE_PLAN_PROFILE],
          lastUpdated: plan.last_updated
        }
    end

    def text
        {
          status: 'generated',
          div: %(<div xmlns="http://www.w3.org/1999/xhtml">#{name}</div>)
        }
    end

    def extension
        [
          drug_plan_extension
        ].flatten.compact
    end

    def identifier
      # TODO: Is this really an identifier?
      [{ value: 'Payer-' + plan.id }]
    end

    def name
        names = plan.marketing_name.split(/\W+/)
        #plan.marketing_name
        names[0] + ' ' + names[1]
    end

    def type
      {
        coding: [
          {
            system: PAYER_PLAN_LIST_CODE_SYSTEM,
            code: type_code,
            display: PAYER_PLAN_LIST_CODE_DISPLAY
          }
        ]
      }
    end

    # Loosely mapping to provide examples of different types
    def type_code
        if plan.marketing_name.include? ' PPO '
            return 'commppo'
        elsif plan.marketing_name.include? ' HMO '
            return 'commhmo'
        else
            return 'mediadv'
        end
    end


    def drug_plan_extension
      {
        url: DRUG_PLAN_REFERENCE_EXTENSION,
        valueReference: {
            reference: 'InsurancePlan/' + DRUG_PLAN_ID_PREFIX + plan.id,
            type: 'InsurancePlan'
        }
      }
    end


    def contact
        value = plan.marketing_url
        valueEmail = plan.email_contact
        return if value.nil? and valueEmail.nil?
  
        [
            {
                purpose: {
                coding: [
                    {
                        system: CONTACT_ENTITY_SYSTEM,
                        code: CONTACT_ENTITY_CODE,
                        display: CONTACT_ENTITY_DISPLAY
                    }
                ]
                },
                telecom: [
                    contact_marketing_url,
                    contact_email
                ]
            }
        ]
    end

    def contact_marketing_url
      value = plan.marketing_url
      return if value.nil?
        
        {
            system: 'url',
            value: plan.marketing_url
        }
      
    end

    def contact_email
        value = plan.email_contact
        return if value.nil?
        
        {
            system: 'email',
            value: plan.email_contact
        }
    end
  end
end
