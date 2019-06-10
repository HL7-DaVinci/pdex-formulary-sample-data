require_relative 'qhp_plan.rb'

module Formulary
  class QHPPlanRepo
    def self.repo
      @repo ||= reset!
    end

    def self.import(raw_qhp_plans)
      raw_qhp_plans.each do |raw_plan|
        repo << QHPPlan.new(raw_plan)
      end
    end

    def self.all
      repo
    end

    def self.ids
      repo.map(&:id)
    end

    def self.reset!
      @repo = []
    end
  end
end
