# frozen_string_literal: true

require 'fhir_models'
require_relative '../formulary'
require_relative 'qhp_drug_tier'
require_relative 'qhp_drug_tier_cost_sharing'
require_relative 'drug_tier_extension_factory'


# TODO DRUG Tiers pharmacy tiers

module Formulary
  # Class to build InsuranceDrugPlan resources from a QHPPlan
  class InsuranceDrugPlanFactory # rubocop:disable Metrics/ClassLength
    attr_reader :plan, :id

    def initialize(plan, id)
      @plan = plan
      @id = id
    end

    def build(entries) # rubocop:disable Metrics/MethodLength
      name.strip!
      
      FHIR::InsurancePlan.new(
        #id: id,
        id: DRUG_PLAN_ID_PREFIX + plan.id,
        meta: meta,
        text: text,
        identifier: identifier,
        status: 'active',
        name: name,
        type: type,
        contact: contact,
        plan: plans
      )
    end

    private

    def meta
        {
          profile: [INSURANCE_DRUG_PLAN_PROFILE],
          lastUpdated: plan.last_updated
        }
    end

    def text
        {
          status: 'generated',
          div: %(<div xmlns="http://www.w3.org/1999/xhtml">#{name}</div>)
        }
    end

    def identifier
      [{ value: DRUG_PLAN_ID_PREFIX + plan.id }]
    end

    def name
        plan.marketing_name
    end

    def type
      {
        coding: [
          {
            system: DRUG_PLAN_LIST_CODE_SYSTEM,
            code: DRUG_PLAN_LIST_CODE_CODE,
            display: DRUG_PLAN_LIST_CODE_DISPLAY
          }
        ]
      }
    end


    def contact
        valueSummary = plan.summary_url
        valueFormulary = plan.formulary_url
        valueEmail = plan.email_contact
        return if valueSummary.nil? and valueFormulary.nil? and valueEmail.nil?
  
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
                    contact_summary_url,
                    contact_formulary_url,
                    contact_email
                ]
            }
        ]
    end

    def contact_summary_url
      value = plan.summary_url
      return if value.nil?
        
        {
            system: 'url',
            value: plan.summary_url
        }
      
    end

    def contact_formulary_url
        value = plan.formulary_url
        return if value.nil?
          
          {
              system: 'url',
              value: plan.formulary_url
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

    def plans
        pharmacy_list = Array.new

        # Put all pharmacy types into an array
        plan.tiers.each do |tier|
            qhp_drug = QHPDrugTier.new(tier)
            qhp_drug.cost_sharing.each do |cost_sharing|
                if(pharmacy_list.include?(cost_sharing.pharmacy_type) == false)
                    pharmacy_list.push(cost_sharing.pharmacy_type)            
                end
            end
        end

        pharmacy_list.map { |pharmacy_type| single_plan(pharmacy_type ) }
    end

    def single_plan(pharmacy_type)
        {
            type: pharmacy_network_type(pharmacy_type),
            network: networks,
            specificCost: specific_costs(pharmacy_type)
        }
    end

    def pharmacy_network_type(pharmacy_type_code)
        {
            coding: [
                {
                    system: PHARMACY_TYPE_SYSTEM,
                    code: pharmacy_type_code,
                    display: PHARMACY_TYPE_DISPLAY[pharmacy_type_code]
                }
            ]
        }
    end

    def networks
        networks = plan.network
        return if networks.nil? || networks.empty?

        networks.map { |network| network_reference(network) }
    end

    def network_reference(value)
        return if value.nil?
  
        {
          display: value
        }
    end

    def specific_costs(pharmacy_type)

        plan.tiers.map { |tier| specific_cost(QHPDrugTier.new(tier), pharmacy_type)}
        
    end

 

    def specific_cost(tier, pharmacy_type)
        return if tier.nil?
        {
            category: specific_cost_category(tier.name),
            benefit: specific_cost_benefits(tier.cost_sharing, pharmacy_type)
        }
    end

    def specific_cost_category(value)
        return if value.nil?
        
        {
                coding: [
                {
                    system: DRUG_TIER_SYSTEM,
                    code: value.downcase,
                    display: DRUG_TIER_DISPLAY[value.downcase]
                }
            ]
          }
    end


    def benefits(value)
        return if value.nil?

        {
            coding: [
                {
                    system: PHARMACY_TYPE_SYSTEM,
                    code: value,
                    display: PHARMACY_TYPE_DISPLAY[value]
                }
            ]
        }
    end

    def specific_cost_benefits(cost_sharing, pharmacy_type)
        return if cost_sharing.nil?
        
        cost_sharing.map { |cost| specific_cost_benefit(cost, pharmacy_type)}

    end

    def specific_cost_benefit(cost, pharmacy_type)
        return if cost.nil?
        return if cost.pharmacy_type != pharmacy_type # Check to see if the current cost benefit is of the current pharmacy type
        {
            type: benefit_type,
            cost: [
                copay_cost(cost),
                coinsurance_cost(cost)
            ]
            #benefit_costs(value)
        }
    end

    def benefit_type
        {
            coding: [
                {
                system: BENEFIT_TYPE_SYSTEM,
                code: BENEFIT_TYPE_CODE,
                display: BENEFIT_TYPE_DISPLAY
                }
            ]
        }
    end

    def copay_cost(cost)
        return if cost.nil?
        {
            type: cost_type('copay'),
            qualifiers: copay_option(cost.copay_option),
            value: {
                value: cost.copay_amount
            }
        }
    end

    def copay_option(option)
        return if option.nil?
        {
            coding: [
                {
                system: COPAY_OPTION_SYSTEM,
                code: option.downcase,
                display: COPAY_OPTION_DISPLAY[option.downcase]
                }
            ]
        }
    end


    def coinsurance_cost(cost)
        return if cost.nil?
        {
            type: cost_type('coinsurance'),
            qualifiers: coinsurance_option(cost.coinsurance_option),
            value: {    
                value: cost.coinsurance_rate,
                system: 'http://unitsofmeasure.org', 
                code: '%'

            }
        }
    end

    def coinsurance_option(option)
        return if option.nil?
        {
            coding: [
                {
                system: COINSURANCE_OPTION_SYSTEM,
                code: option.downcase,
                display: COINSURANCE_OPTION_DISPLAY[option.downcase]
                }
            ]
        }
    end

    def cost_type(value)
        {
            coding: [
                {
                system: BENEFIT_COST_TYPE_SYSTEM,
                code: value
                #display: PHARMACY_TYPE_DISPLAY[value]
                }
            ]
        }
    end
    #def benefit_costs(value)
    #    value.map { |cost| specific_cost_benefit(cost)}
    #end
  end
end
