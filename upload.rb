require 'pry'
require 'git'
require 'httparty'
require 'tmpdir'
require 'fileutils'

FHIR_SERVER = 'http://localhost:8080/r4'

def upload_conformance_resources
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

def upload_sample_resources
  file_path = File.join(__dir__, 'output', '**/*.json')
  filenames =
    Dir.glob(file_path)
      .partition { |filename| filename.include? 'MedicationKnowledge' }
      .flatten
  filenames.each do |filename|
    resource = JSON.parse(File.read(filename), symbolize_names: true)
    response = upload_resource(resource)
    binding.pry unless response.success?
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
  HTTParty.put(
    "#{FHIR_SERVER}/#{resource_type}/#{id}",
    body: resource.to_json,
    headers: { 'Content-Type': 'application/json' }
  )
end


upload_us_core_resources
upload_conformance_resources
upload_sample_resources
