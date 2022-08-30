# frozen_string_literal: true

# Build conformant FHIR resources for the DaVinci PDex US Drug Formulary
module Formulary
  # Payer Insurance Plan profile's official URL
  PAYER_INSURANCE_PLAN_PROFILE = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PayerInsurancePlan"
  # Formulary profile's official URL
  FORMULARY_PROFILE = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-Formulary"
  # Formulary Item profile's official URL
  FORMULARY_ITEM_PROFILE = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyItem"
  # Formulary Drug profile's official URL
  FORMULARY_DRUG_PROFILE = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyDrug"
  # Drug Tier CodeSystem
  DRUG_TIER_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-DrugTierCS"
  # rxnorm CodeSystem
  RXNORM_SYSTEM = "http://www.nlm.nih.gov/research/umls/rxnorm"
  # Pharmacy Benefit Type CodeSystem
  PHARMACY_TYPE_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-PharmacyBenefitTypeCS"
  # Cost share option CodeSystem
  COST_SHARE_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-CostShareOptionCS"
  # Formulart Item CodeSystem
  FORMULARY_ITEM_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-InsuranceItemTypeCS"
  # Insurance product type CodeSystem
  INSURANCE_PRODUCT_TYPE_SYSTEM = "http://hl7.org/fhir/us/davinci-pdex-plan-net/CodeSystem/InsuranceProductTypeCS"
  # Formulary type CodeSystem
  FORMULARY_TYPE_SYSTEM = "http://terminology.hl7.org/CodeSystem/v3-ActCode"
  # Contact entity type CodeSystem
  CONTACT_ENTITY_SYSTEM = "http://terminology.hl7.org/CodeSystem/contactentity-type"
  PLAN_CONTACT_TYPE_CS = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-PlanContactTypeCS"
  # Insurance plan type CodeSystem
  PLAN_TYPE_SYSTEM = "http://terminology.hl7.org/CodeSystem/insurance-plan-type"
  # Benefit cost type CodeSystem
  BENEFIT_COST_TYPE_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-BenefitCostTypeCS"
  # Unit form CodeSystem
  UCUM_SYSTEM = "http://unitsofmeasure.org"
  RELATED_MEDICATION_TYPE_SYSTEM = "http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-RelatedMedicationTypeCS"

  FORMULARY_REFERENCE_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyReference-extension"
  AVAILABILITY_STATUS_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-AvailabilityStatus-extension"
  AVAILABILITY_PERIOD_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-AvailabilityPeriod-extension"
  # Pharmacy benefit type extension
  PHARMACY_TYPE_EXTENSION = "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PharmacyBenefitType-extension"
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
  # Formulary type CodeSystem code
  FORMULARY_TYPE_CS_CODE = "DRUGPOL"
  # Formulary type CodeSystem display
  FORMULARY_TYPE_CS_DISPLAY = "drug policy"
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
  # Copay amount unit
  COPAY_AMOUNT_CODE = "USD"
  # Copay amount unit CodeSystem
  COPAY_AMOUNT_SYSTEM = "urn:iso:std:iso:4217"
  # Pharmacy type CS code => display values
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
  # Drug tier CS code => display values
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
  # Codes qualifying the type of cost share amount (code => display)
  COST_SHARE_OPTION_DISPLAY = {
    "after-deductible" => "After Deductible",
    "before-deductible" => "Before Deductible",
    "no-charge" => "No Charge",
    "no-charge-after-deductible" => "No Charge After Deductible",
    "charge" => "Charge",
    "coinsurance-not-applicable" => "	Coinsurance Not Applicable",
    "copay-not-applicable" => "	Copay Not Applicable",
    "deductible-waived" => "Deductible Waived",
  }.freeze
end
