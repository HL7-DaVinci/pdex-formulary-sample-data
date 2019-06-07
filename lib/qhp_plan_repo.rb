require_relative 'qhp_plan.rb'

class QHPPlanRepo
  attr_reader :repo

  def initialize
    @repo = []
  end

  def import(raw_qhp_plans)
    raw_qhp_plans.each do |raw_plan|
      repo << QHPPlan.new(raw_plan)
    end
  end

  def all
    repo
  end

  def ids
    repo.map(&:id)
  end
end
