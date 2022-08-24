# frozen_string_literal: true

module Formulary
  PAYER_INSURANCE_PLAN_PROFILE = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PayerInsurancePlan"
  FORMULARY_PROFILE = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-Formulary"
  FORMULARY_ITEM_PROFILE = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyItem"
  FORMULARY_DRUG_PROFILE = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyDrug"

  DRUG_TIER_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-DrugTierCS"
  RXNORM_SYSTEM = "http://www.nlm.nih.gov/research/umls/rxnorm"
  PHARMACY_TYPE_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-PharmacyTypeCS"
  COPAY_OPTION_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-CopayOptionCS"
  COINSURANCE_OPTION_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-CoinsuranceOptionCS"
  PAYER_PLAN_LIST_CODE_SYSTEM = "http://hl7.org/fhir/us/davinci-pdex-plan-net/CodeSystem/InsuranceProductTypeCS"
  FORMULARY_LIST_CODE_SYSTEM = "http://terminology.hl7.org/CodeSystem/v3-ActCode"
  FORMULARY_ITEM_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-InsuranceItemTypeCS"
  INSURANCE_PRODUCT_TYPE_SYSTEM = "http://hl7.org/fhir/us/davinci-pdex-plan-net/CodeSystem/InsuranceProductTypeCS"
  FORMULARY_TYPE_SYSTEM = "http://terminology.hl7.org/CodeSystem/v3-ActCode"
  CONTACT_ENTITY_SYSTEM = "http://terminology.hl7.org/CodeSystem/contactentity-type"
  CONTACT_ENTITY_TYPE_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-PlanContactTypeCS"
  PLAN_TYPE_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-PlanTypeCS"
  BENEFIT_COST_TYPE_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-BenefitCostTypeCS"
  UCUM_SYSTEM = "http://unitsofmeasure.org"
  RELATED_MEDICATION_TYPE_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-RelatedMedicationTypeCS"

  FORMULARY_REFERENCE_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyReference-extension"
  AVAILABILITY_STATUS_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-AvailabilityStatus-extension"
  AVAILABILITY_PERIOD_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-AvailabilityPeriod-extension"
  PHARMACY_TYPE_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PharmacyType-extension"
  DRUG_TIER_ID_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-DrugTierID-extension"
  PRIOR_AUTH_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PriorAuthorization-extension"
  PRIOR_AUTH_NEW_START_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PriorAuthorizationNewStartsOnly-extension"
  STEP_THERAPY_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-StepTherapyLimit-extension"
  STEP_THERAPY_NEW_START_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-StepTherapyLimitNewStartsOnly-extension"
  QUANTITY_LIMIT_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-QuantityLimit-extension"
  QUANTITY_LIMIT_DETAIL_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-QuantityLimitDetail-extension"
  QUANTITY_LIMIT_DETAIL_ROLLING_EXTENSION = "Rolling"
  QUANTITY_LIMIT_DETAIL_MAXIMUM_DAILY_EXTENSION = "MaximumDaily"
  QUANTITY_LIMIT_DETAIL_DAYS_SUPPLY_EXTENSION = "DaysSupply"
  PAYER_PLAN_ID_PREFIX = "PayerPlan-"
  FORMULARY_ID_PREFIX = "Formulary-"
  FORMULARY_ITEM_ID_PREFIX = "FormularyItem-"
  DRUG_ID_PREFIX = "Drug-"

  PAYER_PLAN_LIST_CODE_CODE = "mediadv"
  FORMULARY_LIST_CODE_CODE = "DRUGPOL"
  FORMULARY_LIST_CODE_DISPLAY = "drug policy"
  CONTACT_PATINF_CODE = "PATINF"
  CONTACT_PATINF_DISPLAY = "Patient"
  CONTACT_MARKETING_CODE = "MARKETING"
  CONTACT_MARKETING_DISPLAY = "Plan Marketing Information"
  CONTACT_SUMMARY_CODE = "SUMMARY"
  CONTACT_SUMMARY_DISPLAY = "Plan Summary Information"
  CONTACT_FORMULARY_CODE = "FORMULARY"
  CONTACT_FORMULARY_DISPLAY = "Plan Formulary Information"

  PLAN_TYPE_CODE = "drug"
  PLAN_TYPE_DISPLAY = "Drug"

  COPAY_AMOUNT_CODE = "USD"
  COPAY_AMOUNT_SYSTEM = "urn:iso:std:iso:4217"

  PHARMACY_TYPE_DISPLAY = {
    "1-month-in-retail" => "1 month in network retail",
    "1-month-out-retail" => "1 month out of network retail",
    "1-month-in-mail" => "1 month in network mail order",
    "1-month-out-mail" => "1 month out of network mail order",
    "3-month-in-retail" => "3 month in network retail",
    "3-month-out-retail" => "3 month out of network retail",
    "3-month-in-mail" => "3 month in network mail order",
    "3-month-out-mail" => "3 month out of network mail order",
  }.freeze

  DRUG_TIER_DISPLAY = {
    "generic" => "Generic",
    "preferred-generic" => "Preferred Generic",
    "non-preferred-generic" => "Non-preferred Generic",
    "specialty" => "Specialty",
    "brand" => "Brand",
    "preferred-brand" => "Preferred Brand",
    "non-preferred-brand" => "Non-preferred Brand",
    "zero-cost-share-preventative" => "Zero cost-share preventative",
    "medical-service" => "Medical Service",
  }.freeze

  COPAY_OPTION_DISPLAY = {
    "after-deductible" => "After Deductible",
    "before-deductible" => "Before Deductible",
    "no-charge" => "No Charge",
    "no-charge-after-deductible" => "No Charge After Deductible",
  }.freeze

  COINSURANCE_OPTION_DISPLAY = {
    "after-deductible" => "After Deductible",
    "no-charge" => "No Charge",
    "no-charge-after-deductible" => "No Charge After Deductible",
  }.freeze
end
