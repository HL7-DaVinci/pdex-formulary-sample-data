# frozen_string_literal: true

module Formulary
  PAYER_INSURANCE_PLAN_PROFILE = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PayerInsurancePlan'
  INSURANCE_DRUG_PLAN_PROFILE = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-InsuranceDrugPlan'
  FORMULARY_ITEM_PROFILE = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyItem'
  FORMULARY_PROFILE = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyDrug'
  #COVERAGE_PLAN_PROFILE = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-CoveragePlan'

  DRUG_TIER_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-DrugTierCS'
  RXNORM_SYSTEM = 'http://www.nlm.nih.gov/research/umls/rxnorm'
  PHARMACY_TYPE_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-PharmacyTypeCS'
  COPAY_OPTION_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-CopayOptionCS'
  COINSURANCE_OPTION_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-CoinsuranceOptionCS'
  PAYER_PLAN_LIST_CODE_SYSTEM = "http://hl7.org/fhir/us/davinci-pdex-plan-net/CodeSystem/InsuranceProductTypeCS"
  DRUG_PLAN_LIST_CODE_SYSTEM = "http://terminology.hl7.org/CodeSystem/v3-ActCode"
  FORMULARY_ITEM_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-InsuranceItemTypeCS'
  INSURANCE_PRODUCT_TYPE_SYSTEM = 'http://hl7.org/fhir/us/davinci-pdex-plan-net/CodeSystem/InsuranceProductTypeCS'
  DRUG_PLAN_TYPE_SYSTEM = 'http://terminology.hl7.org/CodeSystem/v3-ActCode'
  CONTACT_ENTITY_SYSTEM = 'http://terminology.hl7.org/CodeSystem/contactentity-type'
  BENEFIT_TYPE_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-BenefitTypeCS'
  BENEFIT_COST_TYPE_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-BenefitCostTypeCS'
  UCUM_SYSTEM = 'http://unitsofmeasure.org'
  RELATED_MEDICATION_TYPE_SYSTEM = 'http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-RelatedMedicationTypeCS'

  
  #PLAN_ID_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PlanID-extension'
  DRUG_PLAN_REFERENCE_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-DrugPlanReference-extension'
  AVAILABILITY_STATUS_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-AvailabilityStatus-extension'
  AVAILABILITY_PERIOD_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-AvailabilityPeriod-extension'
  PHARMACY_TYPE_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PharmacyType-extension'
  DRUG_TIER_ID_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-DrugTierID-extension'
  PRIOR_AUTH_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PriorAuthorization-extension'
  PRIOR_AUTH_NEW_START_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PriorAuthorizationNewStartsOnly-extension'
  STEP_THERAPY_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-StepTherapyLimit-extension'
  STEP_THERAPY_NEW_START_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-StepTherapyLimitNewStartsOnly-extension'
  QUANTITY_LIMIT_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-QuantityLimit-extension'
  QUANTITY_LIMIT_DETAIL_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-QuantityLimitDetail-extension'
  QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION = 'Rolling'
  QUANTITY_LIMIT_DETAIL_MAXIMUM_DAILY_EXTENSION = 'MaximumDaily'
  QUANTITY_LIMIT_DETAIL_DAYS_SUPPLY_EXTENSION = 'DaysSupply'


  PAYER_PLAN_ID_PREFIX = "PayerPlan-"
  DRUG_PLAN_ID_PREFIX = "DrugPlan-"
  FORMULARY_ITEM_ID_PREFIX = "FormularyItem-"
  DRUG_ID_PREFIX = "Drug-"


  #DRUG_TIER_DEFINITION_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-DrugTierDefinition-extension'
  #NETWORK_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-Network-extension'
  #SUMMARY_URL_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-SummaryURL-extension'
  #FORMULARY_URL_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyURL-extension'
  #MARKETING_URL_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-MarketingURL-extension'
  #EMAIL_CONTACT_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-EmailPlanContact-extension'
  #PLAN_ID_TYPE_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PlanIDType-extension'
  #DRUG_TIER_ID_EXTENSION = 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-DrugTierID-extension'
  #INTERNAL_DRUG_TIER_ID_EXTENSION = 'drugTierID'
  #MAIL_ORDER_EXTENSION = 'mailOrder'
  #COST_SHARING_EXTENSION = 'costSharing'
  #PHARMACY_TYPE_EXTENSION = 'pharmacyType'
  #COPAY_AMOUNT_EXTENSION = 'copayAmount'
  #COPAY_OPTION_EXTENSION = 'copayOption'
  #COINSURANCE_RATE_EXTENSION = 'coinsuranceRate'
  #COINSURANCE_OPTION_EXTENSION = 'coinsuranceOption'
  PAYER_PLAN_LIST_CODE_CODE = "mediadv"
  PAYER_PLAN_LIST_CODE_DISPLAY = "Medicare Advantage"
  DRUG_PLAN_LIST_CODE_CODE = "DRUGPOL"
  DRUG_PLAN_LIST_CODE_DISPLAY = "drug policy"
  CONTACT_ENTITY_CODE = 'PATINF'
  CONTACT_ENTITY_DISPLAY = "Patient"
  BENEFIT_TYPE_CODE = "drug"
  BENEFIT_TYPE_DISPLAY = "Drug"

  PHARMACY_TYPE_DISPLAY = {
    '1-month-in-retail' => "1 month in network retail",
    '1-month-out-retail' => "1 month out of network retail",
    '1-month-in-mail' => "1 month in network mail order",
    '1-month-out-mail' => "1 month out of network mail order",
    '3-month-in-retail' => "3 month in network retail",
    '3-month-out-retail' => "3 month out of network retail",
    '3-month-in-mail' => "3 month in network mail order",
    '3-month-out-mail' => "3 month out of network mail order"
  }.freeze

  DRUG_TIER_DISPLAY = {
    'generic' => "Generic",
    'preferred-generic' => "Preferred Generic",
    'non-preferred-generic' => "Non-preferred Generic",
    'specialty' => "Specialty",
    'brand' => "Brand",
    'preferred-brand' => "Preferred Brand",
    'non-preferred-brand' => "Non-preferred Brand",
   # 'non-preferred-brand-specialty' => 'Non-preferred brand specialty',
    'zero-cost-share-preventative' => "Zero cost-share preventative",
    'medical-service' => "Medical Service"
  }.freeze


  COPAY_OPTION_DISPLAY = {
    'after-deductible' => "After Deductible",
    'before-deductible' => "Before Deductible",
    'no-charge' => "No Charge",
    'no-charge-after-deductible' => "No Charge After Deductible"
}.freeze

  COINSURANCE_OPTION_DISPLAY = {
    'after-deductible' => "After Deductible",
    'no-charge' => "No Charge",
    'no-charge-after-deductible' => "No Charge After Deductible"
}.freeze

end


