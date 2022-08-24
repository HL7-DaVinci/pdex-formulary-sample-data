# frozen_string_literal: true

require "fhir_models"
require_relative "../formulary"

module Formulary
  # Class to build the FHIR extensions for the quantity limit detail field of the the formulary item profile (Basic Resource)
  class QuantityLimitDetailExtensionFactory
    attr_reader :drug_name, :rolling_extension

    def initialize(drug_name)
      @drug_name = drug_name
      set_rolling_extension
    end
    # Construct a quantityLimitDetail FHIR extension instance
    def build
      FHIR::Extension.new(
        url: QUANTITY_LIMIT_DETAIL_EXTENSION,
        extension: [
          rolling_extension,
          maximum_daily_extension,
          days_supply_extension,
        ].compact,
      )
    end

    private

    # Selects a days supply extension from the sample list DAYS_SUPPLY
    # @return the days supply extension [Object]
    def days_supply_extension
      DAYS_SUPPLY.sample
    end

    # Structure the maximum daily extension based on the Rolling extension
    # @return the maximum daily extension [Hash] or nil
    def maximum_daily_extension
      return if rolling_extension.nil?
      extension = nil
      count = rolling_extension[:valueTiming][:repeat][:count]
      period = rolling_extension[:valueTiming][:repeat][:period]
      if count % period == 0
        extension = {
          url: QUANTITY_LIMIT_DETAIL_MAXIMUM_DAILY_EXTENSION,
          valueQuantity: {
            value: count / period,
          },
        }
      end
      extension
    end

    # Sets @rolling_extension based on the drug form
    # @return @rolling_extension
    def set_rolling_extension
      ext = nil
      pill_form = ["tablet", "capsule", "caplet"].any? { |s| drug_name.downcase.include?(s) }
      paste_form = ["paste", "cream", "ointment", "gel"].any? { |s| drug_name.downcase.include?(s) }
      liquid_form = ["ml", "solution", "suspension"].any? { |s| drug_name.downcase.include?(s) }
      injection_form = drug_name.downcase.include?("injection")
      ophthalmic = drug_name.downcase.include?("ophthalmic")
      if ophthalmic
        ext = OPHTHALMIC_ROLLING.sample
      elsif injection_form
        ext = INJECTION_ROLLING.sample
      elsif pill_form
        ext = PILL_ROLLING.sample
      elsif paste_form
        ext = PASTE_ROLLING.sample
      elsif liquid_form
        ext = LIQUID_ROLLING.sample
      end
      @rolling_extension = ext
    end

    # Selection for tablet, capsule, caplet, etc.
    PILL_ROLLING = [
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 60,
            period: 30,
            periodUnit: "d",
          },
        },
      },
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 30,
            period: 30,
            periodUnit: "d",
          },
        },
      },
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 120,
            period: 30,
            periodUnit: "d",
          },
        },
      },
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 9,
            period: 30,
            periodUnit: "d",
          },
        },
      },
    ].freeze
    # Selection for solution, suspension, etc.
    LIQUID_ROLLING = [
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 60,
            period: 30,
            periodUnit: "d",
          },
        },
      },
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 300,
            period: 30,
            periodUnit: "d",
          },
        },
      },
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 15,
            period: 30,
            periodUnit: "d",
          },
        },
      },
    ].freeze
    # Selection for cream, ointment, gel, paste, etc.
    PASTE_ROLLING = [
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 60,
            period: 30,
            periodUnit: "d",
          },
        },
      },
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 15,
            period: 30,
            periodUnit: "d",
          },
        },
      },
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 100,
            period: 30,
            periodUnit: "d",
          },
        },
      },
    ].freeze
    # Selection injections
    INJECTION_ROLLING = [
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 12,
            period: 30,
            periodUnit: "d",
          },
        },
      },
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 1,
            period: 30,
            periodUnit: "d",
          },
        },
      },
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 15,
            period: 30,
            periodUnit: "d",
          },
        },
      },
    ].freeze
    # Selection for ophthalmic
    OPHTHALMIC_ROLLING = [
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 20,
            period: 30,
            periodUnit: "d",
          },
        },
      },
      {
        url: QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION,
        valueTiming: {
          repeat: {
            count: 30,
            period: 30,
            periodUnit: "d",
          },
        },
      },
    ].freeze
    # Sample days supply extension
    DAYS_SUPPLY = [
      {
        url: QUANTITY_LIMIT_DETAIL_DAYS_SUPPLY_EXTENSION,
        valueTiming: {
          repeat: {
            boundsDuration: {
              value: 365,
              system: "http://unitsofmeasure.org",
              code: "d",
            },
            count: 1,
            period: 180,
            periodUnit: "d",
          },
        },
      },
      nil,
      nil,
      nil,
      nil,
      {
        url: QUANTITY_LIMIT_DETAIL_DAYS_SUPPLY_EXTENSION,
        valueTiming: {
          repeat: {
            boundsDuration: {
              value: 365,
              system: "http://unitsofmeasure.org",
              code: "d",
            },
            count: 2,
            period: 28,
            periodUnit: "d",
          },
        },
      },
    ].freeze
  end
end
