# frozen_string_literal: true

require "date"
require "fhir_models"
require_relative "../formulary"

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
        identifier: identifier,
        status: "active",
        name: name,
        type: type,
        period: period,
        coverageArea: coverageArea,
        contact: contact,
        coverage: coverage,
        plan: plans,
      )
    end

    private

    def meta
      {
        profile: [PAYER_INSURANCE_PLAN_PROFILE],
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
      # TODO: Is this really an identifier?
      [{ value: PAYER_PLAN_ID_PREFIX + plan.id }]
    end

    def name
      names = plan.marketing_name.split(/\W+/)
      #plan.marketing_name
      names[0] + " " + names[1]
    end

    def type
      {
        coding: [
          {
            system: PAYER_PLAN_LIST_CODE_SYSTEM,
            code: type_code,
            display: type_display,
          },
        ],
      }
    end

    # Loosely mapping to provide examples of different types
    def type_code
      if plan.marketing_name.include? " PPO "
        return "commppo"
      elsif plan.marketing_name.include? " HMO "
        return "commhmo"
      else
        return "mediadv"
      end
    end

    # Loosely mapping to provide examples of different types
    def type_display
      if plan.marketing_name.include? " PPO "
        return "Commercial PPO"
      elsif plan.marketing_name.include? " HMO "
        return "Commercial HMO"
      else
        return "Medicare Advantage"
      end
    end

    def period
      current_year = Date.today.year
      {
        "start": "#{current_year}-01-01",
        "end": "#{current_year}-12-31",
      }
    end

    def coverageArea
      choice = ["Location/StateOfCTLocation", "Location/UnitedStatesLocation"]
      [
        {
          "reference": choice.sample,
        },
      ]
    end

    def contact
      valueMarketing = plan.marketing_url
      valueSummary = plan.summary_url
      valueFormulary = plan.formulary_url
      valueEmail = plan.email_contact
      return if valueMarketing.nil? and valueSummary.nil? and valueFormulary.nil? and valueEmail.nil?

      [
        marketing_contact,
        summary_contact,
        formulary_contact,
        email_contact,
      ]
    end

    def marketing_contact
      value = plan.marketing_url
      return if value.nil?

      {

        purpose: {
          coding: [
            {
              system: CONTACT_ENTITY_SYSTEM,
              code: CONTACT_PATINF_CODE,
              display: CONTACT_PATINF_DISPLAY,
            },
            {
              system: CONTACT_ENTITY_TYPE_SYSTEM,
              code: CONTACT_MARKETING_CODE,
              display: CONTACT_MARKETING_DISPLAY,
            },
          ],
        },
        telecom: [
          {
            system: "url",
            value: plan.marketing_url,
          },
        ],
      }
    end

    def summary_contact
      value = plan.summary_url
      return if value.nil?

      {

        purpose: {
          coding: [
            {
              system: CONTACT_ENTITY_SYSTEM,
              code: CONTACT_PATINF_CODE,
              display: CONTACT_PATINF_DISPLAY,
            },
            {
              system: CONTACT_ENTITY_TYPE_SYSTEM,
              code: CONTACT_SUMMARY_CODE,
              display: CONTACT_SUMMARY_DISPLAY,
            },
          ],
        },
        telecom: [
          {
            system: "url",
            value: plan.summary_url,
          },
        ],
      }
    end

    def formulary_contact
      value = plan.formulary_url
      return if value.nil?

      {

        purpose: {
          coding: [
            {
              system: CONTACT_ENTITY_SYSTEM,
              code: CONTACT_PATINF_CODE,
              display: CONTACT_PATINF_DISPLAY,
            },
            {
              system: CONTACT_ENTITY_TYPE_SYSTEM,
              code: CONTACT_FORMULARY_CODE,
              display: CONTACT_FORMULARY_DISPLAY,
            },
          ],
        },
        telecom: [
          {
            system: "url",
            value: plan.formulary_url,
          },
        ],
      }
    end

    def email_contact
      value = plan.email_contact
      return if value.nil?

      {

        purpose: {
          coding: [
            {
              system: CONTACT_ENTITY_SYSTEM,
              code: CONTACT_PATINF_CODE,
              display: CONTACT_PATINF_DISPLAY,
            },
          ],
        },
        telecom: [
          {
            system: "email",
            value: plan.email_contact,
          },
        ],
      }
    end

    def coverage
      [
        {
          extension: extension,
          type: coverage_type,
          benefit: [
            {
              type: {
                coding: [
                  {
                    system: "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-PlanTypeCS",
                    code: "drug",
                  },
                ],
              },
            },
          ],
        },
      ]
    end

    def coverage_type
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

    def extension
      [
        formulary_extension,
      ].flatten.compact
    end

    def formulary_extension
      {
        url: FORMULARY_REFERENCE_EXTENSION,
        valueReference: {
          reference: "InsurancePlan/" + FORMULARY_ID_PREFIX + plan.id,
          type: "InsurancePlan",
        },
      }
    end

    def plans
      [
        {
          type: plan_type, #pharmacy_network_type(pharmacy_type),
          network: networks,
          specificCost: specific_costs,
        #specificCost: pharmacy_list.map { |pharmacy_type| single_plan(pharmacy_type ) }#specific_costs(pharmacy_type)
        },
      ]
      #pharmacy_list = Array.new

      # Put all pharmacy types into an array
      #plan.tiers.each do |tier|
      #    qhp_drug = QHPDrugTier.new(tier)
      #    qhp_drug.cost_sharing.each do |cost_sharing|
      #        if(pharmacy_list.include?(cost_sharing.pharmacy_type) == false)
      #            pharmacy_list.push(cost_sharing.pharmacy_type)
      #        end
      #    end
      #end

      #pharmacy_list.map { |pharmacy_type| single_plan(pharmacy_type ) }
    end

    def single_plan(pharmacy_type)
      {
        type: plan_type, #pharmacy_network_type(pharmacy_type),
        network: networks,
      #specificCost: specific_costs(pharmacy_type)
      }
    end

    def plan_type
      {
        coding: [
          {
            system: PLAN_TYPE_SYSTEM,
            code: PLAN_TYPE_CODE,
            display: PLAN_TYPE_DISPLAY,
          },
        ],
      }
    end

    def pharmacy_network_type(pharmacy_type_code)
      {
        coding: [
          {
            system: PHARMACY_TYPE_SYSTEM,
            code: pharmacy_type_code,
            display: PHARMACY_TYPE_DISPLAY[pharmacy_type_code],
          },
        ],
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
        display: value,
      }
    end

    #Right
    def specific_costs #(pharmacy_type)
      pharmacy_list = Array.new
      # Put all pharmacy types into an array
      plan.tiers.each do |tier|
        qhp_drug = QHPDrugTier.new(tier)
        qhp_drug.cost_sharing.each do |cost_sharing|
          if (!pharmacy_list.include?(cost_sharing.pharmacy_type))
            pharmacy_list.push(cost_sharing.pharmacy_type)
          end
        end
      end

      pharmacy_list.map { |pharmacy_type| specific_cost(pharmacy_type) }
      #plan.tiers.map { |tier| specific_cost(QHPDrugTier.new(tier), pharmacy_type)}

    end

    def specific_cost(pharmacy_type) #(tier, pharmacy_type)
      #return if tier.nil?
      {
        category: pharmacy_network_type(pharmacy_type),
        benefit: benefits(pharmacy_type),

      #, #specific_cost_category(tier.name),
      #benefit: specific_cost_benefits(tier.cost_sharing, pharmacy_type)
      }
    end

    def specific_cost_category(value)
      return if value.nil?

      {
        coding: [
          {
            system: DRUG_TIER_SYSTEM,
            code: value.downcase,
            display: DRUG_TIER_DISPLAY[value.downcase],
          },
        ],
      }
    end

    def benefits(pharmacy_type)
      #[
      #  {
      #    type: pharmacy_network_type(pharmacy_type)
      #  }
      #]
      plan.tiers.map { |tier| benefit_tier(QHPDrugTier.new(tier), pharmacy_type) }
    end

    def benefit_tier(tier, pharmacy_type)
      current_cost = nil
      tier.cost_sharing.each do |cost|
        if cost.pharmacy_type != pharmacy_type
          current_cost = cost
        end
      end

      benefit_tier_cost(tier, current_cost)
      #tier.cost_sharing.map { |cost| benefit_tier_cost(tier, cost, pharmacy_type)}
    end

    def benefit_tier_cost(tier, cost)
      return if tier.nil?
      return if cost.nil?
      #return if cost.pharmacy_type != pharmacy_type # Check to see if the current cost benefit is of the current pharmacy type

      {
        type: specific_cost_category(tier.name),
        cost: [
          copay_cost(cost),
          coinsurance_cost(cost),
        ],
      #cost: costs(tier, pharmacy_type)
      }

      #return if cost.nil?
      #return if cost.pharmacy_type != pharmacy_type # Check to see if the current cost benefit is of the current pharmacy type
      #{
      #    type: benefit_type,
      #    cost: [
      #        copay_cost(cost),
      #        coinsurance_cost(cost)
      #    ]
      #benefit_costs(value)
      #}
    end

    #def specific_cost_benefits(cost_sharing, pharmacy_type)
    #    return if cost_sharing.nil?
    #
    #    cost_sharing.map { |cost| specific_cost_benefit(cost, pharmacy_type)}

    #end
    def costs(tier, pharmacy_type)
      return if tier.nil?
      return if tier.cost_sharing.nil?

      tier.cost_sharing.map { |cost| cost(cost, pharmacy_type) }
    end

    #def cost(cost, pharmacy_type )
    #  return if cost.nil?
    #  return if cost.pharmacy_type != pharmacy_type # Check to see if the current cost benefit is of the current pharmacy type
    #  {
    #      copay_cost(cost)
    #      #coinsurance_cost(cost)
    #        #benefit_costs(value)
    #    }
    #end

    def specific_cost_benefit(cost, pharmacy_type)
      return if cost.nil?
      return if cost.pharmacy_type != pharmacy_type # Check to see if the current cost benefit is of the current pharmacy type
      {
        type: benefit_type,
        cost: [
          copay_cost(cost),
          coinsurance_cost(cost),
        ],
      #benefit_costs(value)
      }
    end

    def benefit_type
      {
        coding: [
          {
            system: BENEFIT_TYPE_SYSTEM,
            code: BENEFIT_TYPE_CODE,
            display: BENEFIT_TYPE_DISPLAY,
          },
        ],
      }
    end

    def copay_cost(cost)
      return if cost.nil?
      {
        type: cost_type("copay"),
        qualifiers: copay_option(cost.copay_option),
        value: {
          value: cost.copay_amount,
          unit: "$",
          system: COPAY_AMOUNT_SYSTEM,
          code: COPAY_AMOUNT_CODE,
        },
      }
    end

    def copay_option(option)
      return if option.nil?
      {
        coding: [
          {
            system: COPAY_OPTION_SYSTEM,
            code: option.downcase,
            display: COPAY_OPTION_DISPLAY[option.downcase],
          },
        ],
      }
    end

    def coinsurance_cost(cost)
      return if cost.nil?
      {
        type: cost_type("coinsurance"),
        qualifiers: coinsurance_option(cost.coinsurance_option),
        value: {
          value: cost.coinsurance_rate * 100,
          system: "http://unitsofmeasure.org",
          code: "%",

        },
      }
    end

    def coinsurance_option(option)
      return if option.nil?
      {
        coding: [
          {
            system: COINSURANCE_OPTION_SYSTEM,
            code: option.downcase,
            display: COINSURANCE_OPTION_DISPLAY[option.downcase],
          },
        ],
      }
    end

    def cost_type(value)
      {
        coding: [
          {
            system: BENEFIT_COST_TYPE_SYSTEM,
            code: value,
          #display: PHARMACY_TYPE_DISPLAY[value]
          },
        ],
      }
    end
  end
end
