# frozen_string_literal: true

require 'pry'
require 'git'
require 'zip'
require 'httparty'
require 'tmpdir'
require 'fileutils'

FHIR_SERVER = 'https://davinci-drug-formulary-ri.logicahealth.org'
PAYERS = []
FORMULARIES = []
LOCATIONS = []
NDOUTS = []

def get_all_insurance_plans
  puts '==============================================================='
  puts 'Getting all InsurancePlan from the server...'
  response = HTTParty.get("#{FHIR_SERVER}/fhir/InsurancePlan", verify: false)
  if response.code == 200
    plans = JSON.parse(response.body, symbolize_names: true)[:entry]
    plans.each do |plan|
      plan = plan[:resource]
      if plan[:meta][:profile].first == 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-PayerInsurancePlan'
        PAYERS << plan
      else
        FORMULARIES << plan
      end
    end
    puts "Found a total of #{PAYERS.size} PAYERS and #{FORMULARIES.size} Formulary plans."
  else
    puts 'Request to get all Insurance plans failed: in #get_all_insurance_plans'
  end
end

def get_related_basic_and_medicationknowledge(formulary_id, output_directory)
  puts '==============================================================='
  puts "Getting all Basic and MedicationKnowledge related to Formulary with ID= #{formulary_id}..."
  params = "?code=http://hl7.org/fhir/us/davinci-drug-formulary/CodeSystem/usdf-InsuranceItemTypeCS%7Cformulary-item&formulary=InsurancePlan/#{formulary_id}&_include=Basic:subject"
  response = HTTParty.get("#{FHIR_SERVER}/fhir/Basic#{params}", verify: false)
  if response.code == 200
    entries = JSON.parse(response.body, symbolize_names: true)[:entry]
    basic_resources = []
    medication_knowledge_resources = []
    entries.each do |entry|
      resource = entry[:resource]
      resource[:resourceType] == 'Basic' ? basic_resources << resource : medication_knowledge_resources << resource
    end
    puts "There are #{basic_resources.size} Basic resources and #{medication_knowledge_resources.size} MedicationKnowledge resources related to Formulary with ID = #{formulary_id}"

    generate_ndjson('Basic', basic_resources, output_directory)
    generate_ndjson('MedicationKnowledge', medication_knowledge_resources, output_directory)
  else
    puts "Request to get all related Basic and MedicationKnowledge resources to formulary with id #{formulary_id} failed: in #get_related_basic_and_medicationknowledge"
  end
end

def get_related_locations(location_ids, output_directory)
  if LOCATIONS.empty?
    puts '==============================================================='
    puts 'Getting all locations from the server...'
    response = HTTParty.get("#{FHIR_SERVER}/fhir/Location", verify: false)
    if response.code == 200
      locations = JSON.parse(response.body, symbolize_names: true)[:entry]
      locations.each do |location|
        LOCATIONS << location[:resource]
      end
    else
      puts 'Request to get all Location resources failed: in #get_related_locations'
    end
  end

  specific_locations = LOCATIONS.find_all { |loc| location_ids.include?(loc[:id]) }
  generate_ndjson('Location', specific_locations, output_directory)
end

def generate_ndjson(resource_type, resource_list, output_directory)
  puts '==============================================================='
  puts "Generating ndjson file of type #{resource_type}..."
  outfile = File.join(output_directory, "#{resource_type}.ndjson")
  ndout = {
    type: resource_type,
    url: "#{FHIR_SERVER}/resources/#{output_directory.split('/').last}/#{resource_type}.ndjson"
  }
  NDOUTS << ndout

  begin
    o = File.open(outfile, 'w')
    puts "Writing #{resource_list.size} #{resource_type} resource instances to #{outfile}..."
    resource_list.each do |instance|
      instance.delete(:resourceType)
      o.puts(JSON.pretty_generate(instance))
    end
  rescue StandardError => e
    puts "An error occured when generating file #{outfile}: #{e.message}"
  ensure
    o.close
  end
end

def generate_export_json(output_directory, request, output)
  export = {
    transactionTime: Time.now.strftime('%FT%T%:z'),
    request: request,
    requiresAccessToken: false,
    output: output
  }
  file_path = File.join(output_directory, 'export.json')
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(export))
  end
end

def generate_payer_bulk_data
  # Specific payer bulk data
  if !PAYERS.empty?
    PAYERS.each do |payer|
      NDOUTS.clear
      request = "#{FHIR_SERVER}/fhir/InsurancePlan/#{payer[:id]}/$export"
      output_directory = File.join('bulk_export', payer[:id])
      FileUtils.mkdir_p(output_directory)
      related_formularies_id = []
      payer[:coverage].each do |coverage|
        formulary = coverage[:extension].find { |ext| ext[:url] == 'http://hl7.org/fhir/us/davinci-drug-formulary/StructureDefinition/usdf-FormularyReference-extension' }
        unless formulary.nil?
          related_formularies_id << formulary[:valueReference][:reference].split('/').last
        end
      end

      related_formularies = FORMULARIES.find_all { |formulary| related_formularies_id.include?(formulary[:id]) }
      related_formularies.prepend(payer)
      generate_ndjson('InsurancePlan', related_formularies, output_directory)

      related_formularies_id.each do |id|
        get_related_basic_and_medicationknowledge(id, output_directory)
      end

      location_ids = []
      if !payer[:coverageArea].nil?
        payer[:coverageArea].each do |area|
          location_ids << area[:reference].split('/').last
        end
      end
      get_related_locations(location_ids, output_directory)

      generate_export_json(output_directory, request, NDOUTS)
    end

  else
    puts 'There are no payers on the server to generate bulk data.'
 end
end

def generate_formulary_bulk_data
  # Specific formulary bulk data
  if !FORMULARIES.empty?
    FORMULARIES.each do |formulary|
      NDOUTS.clear
      request = "#{FHIR_SERVER}/fhir/InsurancePlan/#{formulary[:id]}/$export"
      output_directory = File.join('bulk_export', formulary[:id])
      FileUtils.mkdir_p(output_directory)
      generate_ndjson('InsurancePlan', [formulary], output_directory)
      get_related_basic_and_medicationknowledge(formulary[:id], output_directory)

      location_ids = []
      if !formulary[:coverageArea].nil?
        formulary[:coverageArea].each do |area|
          location_ids << area[:reference].split('/').last
        end
      end
      
      get_related_locations(location_ids, output_directory)

      generate_export_json(output_directory, request, NDOUTS)
    end
  else
    puts 'There are no Formularies on the server to generate bulk data.'
  end
end

def generate_bulk_export
  get_all_insurance_plans
  puts '==============================================================='
  puts 'Creating the Bulk export folder output ...'
  generate_payer_bulk_data
  generate_formulary_bulk_data
end

generate_bulk_export
