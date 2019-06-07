require 'fhir_models'

class FormularyDrugFactory
  attr_reader :drug
  attr_reader :plan_id

  def initialize(plan_id)
    @plan_id = plan_id
  end

  def build(drug)
    @drug = drug
    FHIR::MedicationKnowledge.new(
      code: {
        coding: [
          {
            system: 'http://www.nlm.nih.gov/research/umls/rxnorm',
            code: drug.rxnorm_code,
            display: drug.name
          }
        ]
      }
    )
  end
end
