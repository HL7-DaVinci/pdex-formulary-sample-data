# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'config'
require_relative 'qhp_drug_repo'
require_relative 'qhp_plan_drug'
require_relative 'formulary_drug_factory'

module Formulary
  # This class generates FormularyDrug resources for a particular plan
  class DrugListGenerator
    attr_reader :plan

    def initialize(plan)
      @plan = plan
    end

    def generate
      plan_drugs.each do |drug|
        create_drug(drug)
        increment_id
      end
      return if list.empty?

      write_list
    end

    def id_prefix
      @id_prefix ||= ::Digest::SHA1.hexdigest(plan.id)[0..5]
    end

    private

    def base_output_directory
      'output'
    end

    def count
      @count ||= 1
    end

    def increment_id
      @count += 1
    end

    def create_drug(drug)
      plan_drug = QHPPlanDrug.new(drug, plan)
      id = "#{id_prefix}-#{count.to_s.rjust(5, '0')}"
      resource = FormularyDrugFactory.new(plan_drug).build(id)
      write_drug(resource)
      add_to_list(id)
    end

    def write_drug(resource)
      output_directory = File.join(base_output_directory, id_prefix)
      FileUtils.mkdir_p(output_directory)
      output_path = File.join(output_directory, "#{resource.id}.MedicationKnowledge.json")
      File.open(output_path, 'w') do |file|
        file.write(resource.to_json)
      end
    end

    def write_list
      FileUtils.mkdir_p base_output_directory
      list_path = File.join(base_output_directory, "#{id_prefix}.List.entry.json")
      File.open(list_path, 'w') do |file|
        file.write(JSON.pretty_generate(list))
      end
    end

    def add_to_list(id)
      list << {
        item: {
          reference: "MedicationKnowledge/#{id}"
        }
      }
    end

    def list
      @list ||= []
    end

    def plan_drugs
      @plan_drugs ||=
        QHPDrugRepo
          .drugs_for_plan(plan)
          .uniq(&:rxnorm_code)
          .take(Config.max_drugs_per_plan)
    end
  end
end
