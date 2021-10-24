# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'config'
require_relative 'qhp_drug_repo'
require_relative 'qhp_plan_drug'
require_relative 'formulary_drug_factory'
require_relative 'formulary_item_factory'
require_relative 'payer_insurance_plan_factory'
require_relative 'formulary_factory'

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

      write_payer_insurance_plan
      write_formulary
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

    def create_drug(drug)
      plan_drug = QHPPlanDrug.new(drug, plan)
      id = "#{id_prefix}-#{count.to_s.rjust(5, '0')}" # if the right of the = is not called, it causes the program to crash
      id = plan_drug.rxnorm_code       
      write_resource(FormularyDrugFactory.new(plan_drug).build(plan_drug.rxnorm_code))
      #FormularyDrugFactory.new(plan_drug).build(plan_drug.rxnorm_code)

      add_to_list(id)

      write_resource(FormularyItemFactory.new(plan, plan_drug).build()) 
   
    end

    
    def write_payer_insurance_plan
      write_resource(PayerInsurancePlanFactory.new(plan, id_prefix).build(list))
    end

    def write_formulary
      write_resource(FormularyFactory.new(plan, id_prefix).build(list))
    end


    def write_resource(resource)
      output_directory = File.join(base_output_directory, resource.resourceType)
      
      FileUtils.mkdir_p output_directory
      file_path = File.join(output_directory, "#{resource.id}.#{resource.resourceType}.json")
      
      File.open(file_path, 'w') do |file|
        file.write(resource.to_json)
      end
    end

    def add_to_list(id)
      list << {
        item: {
          reference: "MedicationKnowledge/#{id}"
        }
      }
    end

  end
end
