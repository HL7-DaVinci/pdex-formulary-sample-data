# frozen_string_literal: true

require "pry"
require "git"
require "zip"
require "httparty"
require "tmpdir"
require "fileutils"

FHIR_SERVER = "https://davinci-drug-formulary-ri.logicahealth.org"
PAYERS = []
FORMULARIES = []
LOCATIONS = []
NDOUTS = []

# @param resource_directory [String],  the directory name to search
# @return [Array [String] ] a list of resource file's names from the resource directory
def get_resource_json_files(resource_directory)
  file_path = File.join(resource_directory, "*.json")
  file_names = Dir.glob(file_path)
end

def get_all_insurance_plans
  p "==============================================================="
  p "Reading all InsurancePlan resources..."
  plan_files = get_resource_json_files("output/InsurancePlan")
  plan_files.each do |json_file|
    resource = JSON.parse(File.read(json_file), symbolize_names: true)
    json_file.include?("Payer") ? PAYERS << resource : FORMULARIES << resource
  end
  p "Found a total of #{PAYERS.size} PAYERS and #{FORMULARIES.size} Formulary plans."
end

def get_all_location_resources
  location_files = get_resource_json_files("location_resources")
  location_files.each do |json_file|
    LOCATIONS << JSON.parse(File.read(json_file), symbolize_names: true)
  end
end

# Get all Basic and MK resources linked to the given InsurancePlan
# @param formulary_id [String], the plan id
# @param output_directory [String], the directory where the ndjson file should be written
def get_related_basic_and_medicationknowledge(formulary_id, output_directory)
  p "==============================================================="
  p "Getting all Basic and MedicationKnowledge related to Formulary with ID= #{formulary_id}..."
  id_digits = formulary_id.split("-").last
  basic_files = get_resource_json_files("output/Basic").select { |f_name| f_name.include?(id_digits) }
  basic_resources = basic_files.map { |json_f| JSON.parse(File.read(json_f), symbolize_names: true) }
  # Get the reference ids to retrieve related medication_knowledge_resources
  ref_ids = basic_resources.map { |resource| resource[:id].split("-").last }
  medication_knowledge_files = get_resource_json_files("output/MedicationKnowledge").select { |f_name| ref_ids.any? { |id| f_name.include?(id) } }
  medication_knowledge_resources = medication_knowledge_files.map { |json_f| JSON.parse(File.read(json_f), symbolize_names: true) }

  p "There are #{basic_resources.size} Basic resources and #{medication_knowledge_resources.size} MedicationKnowledge resources related to Formulary with ID = #{formulary_id}"

  generate_ndjson("Basic", basic_resources, output_directory)
  generate_ndjson("MedicationKnowledge", medication_knowledge_resources, output_directory)
end

def extract_location_id_from_reference(reference)
  reference = [] if reference.nil?
  reference.map { |area| area[:reference].split("/").last }
end

# Retrieve location resources with given ids
def get_related_locations(location_ids, output_directory)
  specific_locations = LOCATIONS.find_all { |loc| location_ids.include?(loc[:id]) }
  generate_ndjson("Location", specific_locations, output_directory)
end

# Writing ndjson files for a given resource type
def generate_ndjson(resource_type, resource_list, output_directory)
  p "==============================================================="
  p "Generating ndjson file of type #{resource_type}..."
  outfile = File.join(output_directory, "#{resource_type}.ndjson")
  ndout = {
    type: resource_type,
    url: "#{FHIR_SERVER}/resources/#{output_directory.split("/").last}/#{resource_type}.ndjson",
  }
  NDOUTS << ndout

  begin
    o = File.open(outfile, "w")
    p "Writing #{resource_list.size} #{resource_type} resource instances to #{outfile}..."
    resource_list.each { |instance| o.puts(JSON.generate(instance)) }
  rescue StandardError => e
    puts "An error occured when generating file #{outfile}: #{e.message}"
  ensure
    o.close
  end
end

# Constructs and write the export.json file to the specified destination
def generate_export_json(output_directory, request, output)
  export = {
    transactionTime: Time.now.strftime("%FT%T%:z"),
    request: request,
    requiresAccessToken: false,
    output: output,
  }
  file_path = File.join(output_directory, "export.json")
  File.open(file_path, "w") do |file|
    file.write(JSON.pretty_generate(export))
  end
end

# Group payer insurance resources with their associated Formulary, Basic, MK, and Location resources
def generate_payer_bulk_data
  p "There are no payer resources available to generate bulk data." if PAYERS.empty?

  PAYERS.each do |payer|
    NDOUTS.clear
    request = "#{FHIR_SERVER}/fhir/InsurancePlan/#{payer[:id]}/$export"
    output_directory = File.join("bulk_export", payer[:id])
    FileUtils.mkdir_p(output_directory)
    related_formularies_id = []
    payer[:coverage].each do |coverage|
      formulary = coverage[:extension].find { |ext| ext[:url] == "http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyReference-extension" }
      unless formulary.nil?
        related_formularies_id << formulary[:valueReference][:reference].split("/").last
      end
    end

    related_formularies = FORMULARIES.find_all { |formulary| related_formularies_id.include?(formulary[:id]) }
    related_formularies.prepend(payer)
    generate_ndjson("InsurancePlan", related_formularies, output_directory)

    related_formularies_id.each { |id| get_related_basic_and_medicationknowledge(id, output_directory) }
    location_ids = extract_location_id_from_reference(payer[:coverageArea])
    get_related_locations(location_ids, output_directory)
    generate_export_json(output_directory, request, NDOUTS)
  end
end

# Group each formulary resource with its associated Location, Basic, and MedicationKnowledge resources.
def generate_formulary_bulk_data
  p "There are no Formulary resources available to generate bulk data." if FORMULARIES.empty?
  FORMULARIES.each do |formulary|
    NDOUTS.clear
    request = "#{FHIR_SERVER}/fhir/InsurancePlan/#{formulary[:id]}/$export"
    output_directory = File.join("bulk_export", formulary[:id])
    FileUtils.mkdir_p(output_directory)
    generate_ndjson("InsurancePlan", [formulary], output_directory)
    get_related_basic_and_medicationknowledge(formulary[:id], output_directory)

    location_ids = extract_location_id_from_reference(formulary[:coverageArea])
    get_related_locations(location_ids, output_directory)
    generate_export_json(output_directory, request, NDOUTS)
  end
end

# Generates the grouped bulk data export
def generate_bulk_export
  # Delete the bulk_export directory if it exists.
  FileUtils.rm_rf("bulk_export")

  get_all_insurance_plans
  get_all_location_resources
  p "==============================================================="
  p "Creating the Bulk export folder output ..."
  generate_payer_bulk_data
  generate_formulary_bulk_data
end

generate_bulk_export
