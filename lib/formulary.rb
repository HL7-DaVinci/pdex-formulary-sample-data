# frozen_string_literal: true

module Formulary
  FORMULARY_PROFILE = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyDrug'
  COVERAGE_PLAN_PROFILE = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-CoveragePlan'

  DRUG_TIER_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-DrugTierCS'
  RXNORM_SYSTEM = 'http://www.nlm.nih.gov/research/umls/rxnorm'
  PHARMACY_TYPE_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-PharmacyTypeCS'
  COPAY_OPTION_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-CopayOptionCS'
  COINSURANCE_OPTION_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-CoinsuranceOptionCS'

  DRUG_TIER_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-DrugTierID-extension'
  PLAN_ID_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PlanID-extension'
  PRIOR_AUTH_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PriorAuthorization-extension'
  QUANTITY_LIMIT_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-QuantityLimit-extension'
  STEP_THERAPY_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-StepTherapyLimit-extension'
  DRUG_TIER_DEFINITION_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-DrugTierDefinition-extension'
  NETWORK_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-Network-extension'
  SUMMARY_URL_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-SummaryURL-extension'
  FORMULARY_URL_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyURL-extension'
  MARKETING_URL_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-MarketingURL-extension'
  EMAIL_CONTACT_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-EmailPlanContact-extension'
  PLAN_ID_TYPE_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PlanIDType-extension'
  DRUG_TIER_ID_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-DrugTierID-extension'
  INTERNAL_DRUG_TIER_ID_EXTENSION = 'drugTierID'
  MAIL_ORDER_EXTENSION = 'mailOrder'
  COST_SHARING_EXTENSION = 'costSharing'
  PHARMACY_TYPE_EXTENSION = 'pharmacyType'
  COPAY_AMOUNT_EXTENSION = 'copayAmount'
  COPAY_OPTION_EXTENSION = 'copayOption'
  COINSURANCE_RATE_EXTENSION = 'coinsuranceRate'
  COINSURANCE_OPTION_EXTENSION = 'coinsuranceOption'

  PHARMACY_TYPE_DISPLAY = {
    '1-month-in-retail' => "1 month in network retail: 1 Month Supply via in-network retail pharmacy.",
    '1-month-out-retail' => "1 month out of network retail: 1 Month Supply via out-of-network retail pharmacy.",
    '1-month-in-mail' => "1 month in network mail order: 1 Month Supply via in-network mail order pharmacy.",
    '1-month-out-mail' => "1 month out of network mail order: 1 Month Supply via out-of-network mail order pharmacy.",
    '3-month-in-retail' => "3 month in network retail: 3 Month Supply via in-network retail pharmacy.",
    '3-month-out-retail' => "3 month out of network retail: 3 Month Supply via out-of-network retail pharmacy.",
    '3-month-in-mail' => "3 month in network mail order: 3 Month Supply via in-network mail order pharmacy.",
    '3-month-out-mail' => "3 month out of network mail order: 3 Month Supply via out-of-network mail order pharmacy."
  }.freeze

  DRUG_TIER_DISPLAY = {
    'generic' => "Generic: Commonly prescribed generic drugs that cost more than drugs in the ‘preferred generic’ tier.",
    'preferred-generic' => "Preferred Generic: Commonly prescribed generic drugs.",
    'non-preferred-generic' => "Non-preferred Generic: Generic drugs that cost more than drugs in ‘generic’ tier.",
    'specialty' => "Specialty: Drugs used to treat complex conditions like cancer and multiple sclerosis. They can be generic or brand name, and are typically the most expensive drugs on the formulary.",
    'brand' => "Brand: Brand name drugs that cost more than ‘preferred brand’ drugs.",
    'preferred-brand' => "Preferred Brand: Brand name drugs",
    'non-preferred-brand' => "Non-preferred Brand: Brand name drugs that cost more than ‘brand’ drugs.",
   # 'non-preferred-brand-specialty' => 'Non-preferred brand specialty',
    'zero-cost-share-preventative' => "Zero cost-share preventative: Preventive medications and products available at no cost.",
    'medical-service' => "Medical Service: Drugs that must be administered by a clinician or in a facility and may be covered under a medical benefit."
  }.freeze


  COPAY_OPTION_DISPLAY = {
    'after-deductible' => "After Deductible: The consumer first pays the deductible, and after the deductible is met, the consumer is responsible only for the copay (this indicates that this benefit is subject to the deductible).",
    'before-deductible' => "Before Deductible: The consumer first pays the copay, and any net remaining allowed charges accrue to the deductible (this indicates that this benefit is subject to the deductible).",
    'no-charge' => "No Charge: No cost sharing is charged (this indicates that this benefit is not subject to the deductible).",
    'no-charge-after-deductible' => "No Charge After Deductible: The consumer first pays the deductible, and after the deductible is met, no copayment is charged (this indicates that this benefit is subject to the deductible)."
}.freeze

  COINSURANCE_OPTION_DISPLAY = {
    'after-deductible' => "After Deductible: The consumer first pays the deductible, and after the deductible is met, the consumer pays the coinsurance portion of allowed charges (this indicates that this benefit is subject to the deductible).",
    'no-charge' => "No Charge: No cost sharing is charged (this indicates that this benefit is not subject to the deductible).",
    'no-charge-after-deductible' => "No Charge After Deductible: The consumer first pays the deductible, and after thedeductible is met, no coinsurance is charged (this indicates that this benefit is subject to the deductible)"
}.freeze

end


