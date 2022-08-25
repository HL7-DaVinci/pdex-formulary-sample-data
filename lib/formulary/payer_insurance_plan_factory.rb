require "date"
require "fhir_models"
require_relative "../formulary"
require_relative "qhp_drug_tier"

module Formulary
  # Class to build PayerInsurancePlan resources from a QHPPlan
  class PayerInsurancePlanFactory
    attr_reader :plan

    def initialize(plan)
      @plan = plan
    end

    def build
      name.strip!

      FHIR::InsurancePlan.new(
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
      "#{names[0]} #{names[1]}"
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
      contact_list = [
        marketing_contact,
        summary_contact,
        formulary_contact,
        email_contact,
      ].compact

      return contact_list if !contact_list.empty?
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
            value: value,
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
            value: value,
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
            value: value,
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
            value: value,
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
          type: plan_type,
          network: networks,
          specificCost: specific_costs,
        },
      ]
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

    # @return a list of networks [Array] or nil if no networks
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

    # Constructs the list of cost sharing info per pharmacy type.
    def specific_costs
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
    end

    # Constructs a specific drug cost per pharmacy type
    def specific_cost(pharmacy_type)
      {
        category: pharmacy_network_type(pharmacy_type),
        benefit: benefits(pharmacy_type),
      }
    end

    def pharmacy_network_type(pharmacy_type)
      {
        coding: [
          {
            system: PHARMACY_TYPE_SYSTEM,
            code: pharmacy_type,
            display: PHARMACY_TYPE_DISPLAY[pharmacy_type],
          },
        ],
      }
    end

    # @return cost benefits [Array] per tier and pharmacy_type
    def benefits(pharmacy_type)
      plan.tiers.map { |tier| benefit_tier(QHPDrugTier.new(tier), pharmacy_type) }
    end

    # Benefit per tier in a given pharmacy type
    def benefit_tier(tier, pharmacy_type)
      current_cost = nil
      tier.cost_sharing.each do |cost|
        if cost.pharmacy_type != pharmacy_type
          current_cost = cost
        end
      end

      benefit_tier_cost(tier, current_cost)
    end

    # Cost sharing benefit of a given tier
    def benefit_tier_cost(tier, cost)
      return if tier.nil? || cost.nil?

      {
        type: specific_cost_category(tier.name),
        cost: [
          copay_cost(cost),
          coinsurance_cost(cost),
        ],
      }
    end

    # @return the tier category details
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

    # @return copay details
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

    def cost_type(value)
      {
        coding: [
          {
            system: BENEFIT_COST_TYPE_SYSTEM,
            code: value,
          },
        ],
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
  end
end
