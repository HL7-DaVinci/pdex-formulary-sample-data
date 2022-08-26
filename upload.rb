require "pry"
require "git"
require "zip"
require "httparty"
require "tmpdir"
require "fileutils"
require "optparse"

# Retrieve options from command line arguments
options = OpenStruct.new
OptionParser.new do |opts|
  opts.on("-f", "--fhir_server FHIRSERVER", "The FHIR server to connect to") { |v| options.fhir_server = v }
  opts.on("-c", "--conformance_url DEFINITIONSURL", "The url to download the conformance resources") { |v| options.conformance_url = v }
end.parse!

# Read the const variables from options or set default value.
FHIR_SERVER = options.fhir_server || "http://localhost:8080/fhir"
CONFORMANCE_DEFINITIONS_URL = options.conformance_url || "https://build.fhir.org/ig/HL7/davinci-pdex-formulary/branches/master/definitions.json.zip"
FAILED_UPLOAD = []

def upload_conformance_resources
  definitions_data = HTTParty.get(CONFORMANCE_DEFINITIONS_URL, verify: false)
  definitions_file = Tempfile.new
  begin
    definitions_file.write(definitions_data)
  ensure
    definitions_file.close
  end

  Zip::File.open(definitions_file.path) do |zip_file|
    conf_resources = zip_file.entries
      .select { |entry| entry.name.end_with? ".json" }
      .reject { |entry| entry.name.start_with? "ImplementationGuide" }
    puts "Uploading #{conf_resources.count} conformance resources..."
    conf_resources.each do |entry|
      resource = JSON.parse(entry.get_input_stream.read, symbolize_names: true)
      response = upload_resource(resource)
      FAILED_UPLOAD << resource unless response&.success?
    end
  end
ensure
  definitions_file.unlink
end

def upload_sample_resources
  location_file_path = File.join(__dir__, "location_resources", "*.json")
  file_path = File.join(__dir__, "output", "**/*.json")
  filenames = Dir.glob([file_path, location_file_path])
  # .partition { |filename| filename.include? "InsurancePlan" }
  # .flatten
  puts "Uploading #{filenames.length} resources"
  filenames.each_with_index do |filename, index|
    resource = JSON.parse(File.read(filename), symbolize_names: true)
    response = upload_resource(resource)
    FAILED_UPLOAD << resource unless response&.success?
    if index % 100 == 0
      puts "#{FAILED_UPLOAD.count} out of #{index} attempted resources failed to be uploaded successfully."
    end
  end
end

# def upload_us_core_resources
#   file_path = File.join(__dir__, "us-core", "*.json")
#   filenames =
#     Dir.glob(file_path)
#       .partition { |filename| filename.include? "ValueSet" }
#       .flatten
#       .partition { |filename| filename.include? "CodeSystem" }
#       .flatten
#   filenames.each do |filename|
#     resource = JSON.parse(File.read(filename), symbolize_names: true)
#     response = upload_resource(resource)
#     binding.pry unless response.success?
#   end
# end

def upload_resource(resource)
  resource_type = resource[:resourceType]
  id = resource[:id]
  begin
    HTTParty.put(
      "#{FHIR_SERVER}/#{resource_type}/#{id}",
      body: resource.to_json,
      headers: { 'Content-Type': "application/json" },
    )
  rescue => e
    puts e.message
  end
end

def retry_failed_upload
  while !FAILED_UPLOAD.empty?
    puts "#{FAILED_UPLOAD.count} resource(s) failed to upload. Retrying..."
    failed_upload_copy = FAILED_UPLOAD.dup
    FAILED_UPLOAD.clear
    failed_upload_copy.each do |resource|
      response = upload_resource(resource)
      FAILED_UPLOAD << resource unless response&.success?
    end
  end
end

############## Running the upload methods #################

# upload_us_core_resources
upload_conformance_resources
upload_sample_resources
retry_failed_upload
