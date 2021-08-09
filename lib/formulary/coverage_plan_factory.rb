# frozen_string_literal: true

require 'fhir_models'
require_relative '../formulary'
require_relative 'qhp_drug_tier'
require_relative 'drug_tier_extension_factory'

module Formulary
  # Class to build CoveragePlan resources from a QHPPlan
  class CoveragePlanFactory # rubocop:disable Metrics/ClassLength
    attr_reader :plan, :id

    def initialize(plan, id)
      @plan = plan
      @id = id
    end

    def build(entries) # rubocop:disable Metrics/MethodLength
      name.strip!

      FHIR::List.new(
        id: id,
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
        drug_tier_extensions,
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
      [{ value: plan.id }]
    end

    def text
      {
        status: 'generated',
        div: %(<div xmlns="http://www.w3.org/1999/xhtml">#{name}</div>)
      }
    end

    def drug_tier_extensions
      plan.tiers.map { |tier| DrugTierExtensionFactory.new(QHPDrugTier.new(tier)).build }
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
