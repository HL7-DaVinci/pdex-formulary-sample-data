require_relative 'qhp_drug'

class QHPDrugRepo
  attr_reader :repo

  def initialize
    @repo = Hash.new { |hash, key| hash[key] = [] }
  end

  def import(raw_qhp_drugs)
    raw_qhp_drugs.each do |raw_drug|
      drug = QHPDrug.new(raw_drug)
      drug.plans.each do |drug_plan|
        plan_id = drug_plan[:plan_id]
        repo[plan_id] << drug
      end
    end
  end

  def drugs_for_plan(plan_id)
    repo[plan_id]
  end

  def plans
    repo.keys
  end
end
