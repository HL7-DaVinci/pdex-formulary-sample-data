# QHP to FHIR

This project uses QHP data to create FHIR resources based on the [DaVinci US Drug Formulary Implementation Guide](http://build.fhir.org/ig/HL7/davinci-pdex-formulary/). Currently, the following are created:

- [MedicationKnowledge](http://hl7.org/fhir/R4/medicationknowledge.html) resources (based on the [FormularyDrug](http://build.fhir.org/ig/HL7/davinci-pdex-formulary/StructureDefinition-usdf-FormularyDrug.html) profile)
- The `entry` field for a [List](http://hl7.org/fhir/R4/list.html) (based on the [CoveragePlan](http://build.fhir.org/ig/HL7/davinci-pdex-formulary/StructureDefinition-usdf-CoveragePlan.html) profile) containing references for the created MedicationKnowledge resources

## Instructions

### Generate

- `bundle install`
- edit `config.yml` as needed
- `bundle exec ruby generate.rb`

The generated files are placed in `output/`

### Upload

- `bundle install`
- `bundle exec ruby upload.rb`
