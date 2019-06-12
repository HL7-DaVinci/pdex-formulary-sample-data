# frozen_string_literal: true

require 'fhir_models'
require_relative '../formulary'
require_relative 'qhp_drug_tier'

# rubocop:disable Metrics/ClassLength
module Formulary
  # Class to build CoveragePlan resources from a QHPPlan
  class CoveragePlanFactory
    attr_reader :plan

    def initialize(plan)
      @plan = plan
    end

    def build(entries)
      FHIR::List.new(
        meta: meta,
        identifier: identifier,
        text: text,
        status: 'current',
        mode: 'snapshot',
        title: name,
        date: plan.last_updated,
        entry: entries,
        extension: extension
      )
    end

    private

    def name
      plan.marketing_name
    end

    def id_type
      plan.id_type
    end

    def extension
      [
        drug_tier_definition_extensions,
        network_extensions,
        summary_url_extension,
        formulary_url_extension,
        email_contact_extension,
        marketing_url_extension,
        plan_id_type_extension
      ].flatten.compact
    end

    def meta
      { profile: [COVERAGE_PLAN_PROFILE] }
    end

    def identifier
      # TODO: Is this really an identifier?
      [{ value: id_type }]
    end

    def text
      {
        status: 'generated',
        div: %(<div xmlns="http://www.w3.org/1999/xhtml">#{name}</div>)
      }
    end

    def drug_tier_definition_extensions
      plan.tiers.map { |tier| drug_tier_definition_extension(QHPDrugTier.new(tier)) }
    end

    def drug_tier_definition_extension(tier)
      {
        url: DRUG_TIER_DEFINITION_EXTENSION,
        extension: [
          drug_tier_id_extension(tier),
          mail_order_extension(tier),
          cost_sharing_extensions(tier)
        ].flatten.compact
      }
    end

    def cost_sharing_extensions(tier)
      tier.cost_sharing.map { |cost| cost_sharing_extension(OpenStruct.new(cost)) }
    end

    def drug_tier_id_extension(tier)
      {
        url: DRUG_TIER_ID_EXTENSION,
        valueCodeableConcept: {
          coding: [
            {
              system: DRUG_TIER_SYSTEM,
              code: tier.name,
              display: tier.name
            }
          ]
        }
      }
    end

    def mail_order_extension(tier)
      value = tier.mail_order?
      return if value.nil?

      {
        url: MAIL_ORDER_EXTENSION,
        valueBoolean: value
      }
    end

    def cost_sharing_extension(cost)
      {
        url: COST_SHARING_EXTENSION,
        extension: [
          pharmacy_type_extension(cost),
          copay_amount_extension(cost),
          coinsurance_rate_extension(cost),
          copay_option_extension(cost),
          coinsurance_option_extension(cost)
        ].compact
      }
    end

    def pharmacy_type_extension(cost)
      value = cost.pharmacy_type
      return if value.nil?

      {
        url: PHARMACY_TYPE_EXTENSION,
        valueCodeableConcept: {
          coding: [
            {
              system: PHARMACY_TYPE_SYSTEM,
              code: value,
              display: value
            }
          ]
        }
      }
    end

    def copay_amount_extension(cost)
      value = cost.copay_amount
      return if value.nil?

      {
        url: COPAY_AMOUNT_EXTENSION,
        valueMoney: {
          value: value
        }
      }
    end

    def coinsurance_rate_extension(cost)
      value = cost.coinsurance_rate
      return if value.nil?

      {
        url: COINSURANCE_RATE_EXTENSION,
        valueDecimal: value
      }
    end

    def copay_option_extension(cost)
      value = cost.copay_opt
      return if value.nil?

      {
        url: COPAY_OPTION_EXTENSION,
        valueCodeableConcept: {
          coding: [
            {
              system: COPAY_OPTION_SYSTEM,
              code: value,
              display: value
            }
          ]
        }
      }
    end

    def coinsurance_option_extension(cost)
      value = cost.coinsurance_opt
      return if value.nil?

      {
        url: COINSURANCE_OPTION_EXTENSION,
        valueCodeableConcept: {
          coding: [
            {
              system: COINSURANCE_OPTION_SYSTEM,
              code: value,
              display: value
            }
          ]
        }
      }
    end

    def network_extensions
      networks = plan.network
      return if networks.nil? || networks.empty?

      networks.map { |network| network_extension(network) }
    end

    def network_extension(value)
      return if value.nil?

      {
        url: NETWORK_EXTENSION,
        valueString: value
      }
    end

    def summary_url_extension
      value = plan.summary_url
      return if value.nil?

      {
        url: SUMMARY_URL_EXTENSION,
        valueString: value
      }
    end

    def formulary_url_extension
      value = plan.formulary_url
      return if value.nil?

      {
        url: FORMULARY_URL_EXTENSION,
        valueString: value
      }
    end

    def email_contact_extension
      value = plan.email_contact
      return if value.nil?

      {
        url: EMAIL_CONTACT_EXTENSION,
        valueString: value
      }
    end

    def marketing_url_extension
      value = plan.marketing_url
      return if value.nil?

      {
        url: MARKETING_URL_EXTENSION,
        valueString: value
      }
    end

    def plan_id_type_extension
      value = plan.id_type
      return if value.nil?

      {
        url: PLAN_ID_TYPE_EXTENSION,
        valueString: value
      }
    end
  end
end
# rubocop:enable Metrics/ClassLength
