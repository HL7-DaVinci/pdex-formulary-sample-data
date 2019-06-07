class QHPPlan
  attr_reader :raw_plan

  def initialize(raw_plan)
    @raw_plan = raw_plan.freeze
  end

  def id
    @id ||= raw_plan[:plan_id]
  end
end
