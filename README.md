# QHP to FHIR

This project uses QHP data to create FHIR resources based on the [DaVinci US Drug Formulary Implementation Guide Draft STU2](https://build.fhir.org/ig/HL7/davinci-pdex-formulary/branches/master/index.html). Currently, the following are created:

- __[PayerInsurancePlan](https://build.fhir.org/ig/HL7/davinci-pdex-formulary/branches/master/StructureDefinition-usdf-PayerInsurancePlan)__\
The PayerInsurancePlan profile of the FHIR R4 [InsurancePlan](http://hl7.org/fhir/R4/insuranceplan.html) resource defines the top level package of health insurance coverage benefits that a payer offers.

- __[Formulary](https://build.fhir.org/ig/HL7/davinci-pdex-formulary/branches/master/StructureDefinition-usdf-Formulary.html)__\
The Formulary profile of the FHIR R4 [InsurancePlan](http://hl7.org/fhir/R4/insuranceplan.html) describes a prescription drug insurance offering comprised of drug benefits including a definition of drug tiers and their associated cost-sharing models and additional information about the plan, such as networks, a coverage area, contact information, etc.

- __[FormularyItem](https://build.fhir.org/ig/HL7/davinci-pdex-formulary/branches/master/StructureDefinition-usdf-FormularyItem.html)__\
The FormularyItem profile of the FHIR R4 [Basic](http://hl7.org/fhir/R4/basic.html) describes a drug's relationship to a drug plan, including drug tier, prior authorization requirements, and more. The set of FormuaryItem resrouces associated with a particular drug plan represents the drug plans formulary.

- __[FormularyDrug](https://build.fhir.org/ig/HL7/davinci-pdex-formulary/branches/master/StructureDefinition-usdf-FormularyDrug.html)__\
The FormularyDrug profile of the FHIR R4 [MedicationKnowledge](http://hl7.org/fhir/medicationknowledge.html) resource provides information about a prescribable drug which may be part of a formulary including its RxNorm code, synonyms, and optionally drug classification and alternatives.

## Functionalities

The application has four main functions:
- __Generate formulary data samples__: this is handled by the [generate.rb](https://github.com/HL7-DaVinci/pdex-formulary-sample-data/blob/master/scripts/generate.rb) script, which generates conformant data samples for each profile listed above.

- __Populate a FHIR server with the data__: this is handled by the [upload.rb](https://github.com/HL7-DaVinci/pdex-formulary-sample-data/blob/master/scripts/upload.rb) script.

- __Generate the ndjson files__: this is handled by the [convertNDJSON.rb](https://github.com/HL7-DaVinci/pdex-formulary-sample-data/blob/master/scripts/convertNDJSON.rb) script, which generates the ndjson files for each profile to be used for __bulk export__ requests of all drug formulary data (e.g. `[base]/InsurancePlan/$export`).

- __Generate ndjon files grouped by InsurancePlan__: this is handled by the [plan_specific_ndjson.rb](https://github.com/HL7-DaVinci/pdex-formulary-sample-data/blob/master/scripts/plan_specific_ndjson.rb) script, which generates formularies ndjson files classified by individual InsurancePlan. This is useful for plan specific __bulk export__ requests (e.g. `[base]/InsurancePlan/[id]/$export`).

---
# Installing and Running

This is a Ruby application and currently, it can only be run on development mode.

## Prerequisites
You should have the following programs installed to run this application:
- [Ruby](https://www.ruby-lang.org/)
- [Bundler](https://bundler.io/)

## Installation

1. __Clone this repository__
```
git clone git@github.com:HL7-DaVinci/pdex-formulary-sample-data.git
```
2. __Change directory into the project directory and pull in the dependencies__
```
cd pdex-formulary-sample-data
bundle install
```
## Running Instructions

### Generate Sample Data

1. Edit the properties file (`config.yml`) as needed. By default,the app will generate a max of __3000__ drugs per formulary.
2. Run the `generate.rb` script on the command line
```
bundle exec ruby scripts/generate.rb
```

The generated files are placed in the `output/` folder.
> the `output` directory is not tracked by git.

### Upload Sample Data to a Server

Run the `upload.rb` script to upload the sample data to a server.

```
bundle exec ruby scripts/upload.rb
```
By default, the FHIR server base URL to upload the data is set to `http://localhost:8080/fhir`. The script also upload the conformance definition resources (code systems, search parameters, structure definitions, and value sets ) to the server. The URL to download those conformance resources is also set to a default value (the download URL of the current version of the implementation guide).

Command-line arguments may be provided to specify the server base URL and definitions URL to be used.

```
bundle exec ruby scripts/upload.rb -f http://exampleserver.com -c http://download-definitions-url.json.zip
```

Full usage info can be printed by passing the -h (help) option.
```
bundle exec ruby scripts/upload.rb -h
```

### Generate Bulk Export Files

Run the `convertNDJSON.rb` script to generate `ndjson` files for each profile using the sample data generated [above](#generate-sample-data "Goto generate-sample-data").

```
bundle exec ruby scripts/convertNDJSON.rb
```

This will read all the files in the `output` directory and generate the new files in the `export` directory.

> The `export` directory is not tracked by git.

To generate `ndjson` files grouping each insurance plan with their associated formulary data, run the `plan_specific_ndjson.rb` script:

```
bundle exec ruby scripts/plan_specific_ndjson.rb
```
This will read all the files in the `output` directory and generate the new files in the `bulk_export` directory.

> The `bulk_export` directory is not tracked by git.

The generated ndjson files can be copied to the appropriate directory/location on the server to be used as a response to __bulk export__ requests.
