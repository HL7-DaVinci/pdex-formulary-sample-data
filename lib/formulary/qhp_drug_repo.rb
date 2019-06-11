# frozen_string_literal: true

require_relative 'qhp_drug'

module Formulary
  # Simple in-memory storage for instances of QHPDrug
  class QHPDrugRepo
    def self.repo
      @repo ||= reset!
    end

    def self.import(raw_qhp_drugs)
      raw_qhp_drugs.each do |raw_drug|
        repo << QHPDrug.new(raw_drug)
      end
    end

    def self.drugs_for_plan(plan)
      repo.select { |drug| drug.in_plan? plan.id }
    end

    def self.all
      repo
    end

    def self.reset!
      @repo = []
    end
  end
end
