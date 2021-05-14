# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module Formulary
  # class to build the FHIR extensions for drug tiers
  class DrugTierExtensionFactory # rubocop:disable Metrics/ClassLength
    attr_reader :tier

    def initialize(tier)
      @tier = tier
    end

    def build
      FHIR::Extension.new(
        url: DRUG_TIER_DEFINITION_EXTENSION,
        extension: [
          drug_tier_id_extension,
          mail_order_extension,
          cost_sharing_extensions
        ].flatten.compact
      )
    end

    private

    def cost_sharing_extensions
      tier.cost_sharing.map { |cost| cost_sharing_extension(cost) }
    end

    def drug_tier_id_extension
      return nil if tier.nil? || tier.name.nil?
      {
        url: INTERNAL_DRUG_TIER_ID_EXTENSION,
        valueCodeableConcept: {
          coding: [
            {
              system: DRUG_TIER_SYSTEM,
              code: tier.name.downcase,
              display: DRUG_TIER_DISPLAY[tier.name]
            }
          ]
        }
      }
    end

    def mail_order_extension
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
              display: PHARMACY_TYPE_DISPLAY[value]
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
      value = cost.copay_option
      return if value.nil?

      {
        url: COPAY_OPTION_EXTENSION,
        valueCodeableConcept: {
          coding: [
            {
              system: COPAY_OPTION_SYSTEM,
              code: value,
              display: value.split('-').map(&:capitalize).join(' ')
            }
          ]
        }
      }
    end

    def coinsurance_option_extension(cost)
      value = cost.coinsurance_option
      return if value.nil?

      {
        url: COINSURANCE_OPTION_EXTENSION,
        valueCodeableConcept: {
          coding: [
            {
              system: COINSURANCE_OPTION_SYSTEM,
              code: value,
              display: value.split('-').map(&:capitalize).join(' ')
            }
          ]
        }
      }
    end
  end
end
# rubocop:enable Metrics/MethodLength
