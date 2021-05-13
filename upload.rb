require 'pry'
require 'git'
require 'zip'
require 'httparty'
require 'tmpdir'
require 'fileutils'

FHIR_SERVER = 'http://localhost:8080/plan-net/fhir'

def upload_conformance_resources_from_git
  begin
    file_path = File.join(Dir.tmpdir, SecureRandom.uuid)
    git_repo = Git.clone('https://github.com/HL7/davinci-pdex-formulary.git', file_path)
    tree = git_repo.gtree('HEAD')
    files = tree.subdirectories['resources'].files
    files
      .select { |filename, _| filename.end_with? 'json' }
      .each do |filename, data|
        resource = JSON.parse(data.contents, symbolize_names: true)
        response = upload_resource(resource)
        binding.pry unless response.success?
      end
  ensure
    FileUtils.rm_rf(file_path)
  end
end

def upload_conformance_resources
  definitions_url = 'http://build.fhir.org/ig/HL7/davinci-pdex-formulary/definitions.json.zip'
  definitions_data = HTTParty.get(definitions_url, verify: false)
  definitions_file = Tempfile.new
  begin
    definitions_file.write(definitions_data)
  ensure
    definitions_file.close
  end

  Zip::File.open(definitions_file.path) do |zip_file|
    zip_file.entries
      .select { |entry| entry.name.end_with? '.json' }
      .reject { |entry| entry.name.start_with? 'ImplementationGuide' }
      .each do |entry|
        resource = JSON.parse(entry.get_input_stream.read, symbolize_names: true)
        response = upload_resource(resource)
        # binding.pry unless response.success?
      end
  end
ensure
  definitions_file.unlink
end

def upload_devoted_resources
  file_path = File.join(__dir__, 'output', '**/*.json')
  filenames =
    Dir.glob(file_path)
      .partition { |filename| filename.include? 'List' }
      .flatten
  puts "Uploading #{filenames.length} resources"
  filenames.each_with_index do |filename, index|
    resource = JSON.parse(File.read(filename), symbolize_names: true)
    response = upload_resource(resource)
    # binding.pry unless response.success?
    if index % 100 == 0
      puts index
    end
  end
end

def upload_us_core_resources
  file_path = File.join(__dir__, 'us-core', '*.json')
  filenames =
    Dir.glob(file_path)
      .partition { |filename| filename.include? 'ValueSet' }
      .flatten
      .partition { |filename| filename.include? 'CodeSystem' }
      .flatten
  filenames.each do |filename|
    resource = JSON.parse(File.read(filename), symbolize_names: true)
    response = upload_resource(resource)
    binding.pry unless response.success?
  end
end

def upload_resource(resource)
  resource_type = resource[:resourceType]
  id = resource[:id]
  begin
    HTTParty.put(
      "#{FHIR_SERVER}/#{resource_type}/#{id}",
      body: resource.to_json,
      headers: { 'Content-Type': 'application/json' }
    )
  rescue StandardError
  end
end


# upload_us_core_resources
upload_conformance_resources
upload_devoted_resources
