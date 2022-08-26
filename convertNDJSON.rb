require "json"
require "pry"
require "optparse"

# Retrieve options from command line arguments
options = OpenStruct.new
OptionParser.new do |opts|
  opts.on("-f", "--fhir_server FHIRSERVER", "The FHIR server base url to be used") { |v| options.fhir_server = v }
end.parse!

FHIR_SERVER_BASE = options.fhir_server || "https://davinci-drug-formulary-ri.logicahealth.org"

ndouts = []
FileUtils.mkdir_p("export/")
Dir.glob("output/*/") do |typedir|
  puts "working on input directory: #{typedir}..."
  resourceType = File.basename(typedir)
  url = "#{FHIR_SERVER_BASE}/resources/#{resourceType}.ndjson"
  ndouts << {
    "type" => resourceType,
    "url" => url,
  }
  outfile = "export/#{resourceType}.ndjson"
  puts "writing to #{outfile}"
  o = File.open(outfile, "w")
  Dir.glob("#{typedir}/*.json") do |jsonfile|
    puts "working on: #{jsonfile}"
    s = File.read(jsonfile)
    h = JSON.parse(s)
    o.puts(JSON.generate(h))
  end
  o.close
end
output = {
  "transactionTime" => Time.now.strftime("%d/%m/%Y %H:%M"),
  "request" => "#{FHIR_SERVER_BASE}/fhir/$export",
  "requiresAccessToken" => false,
  "output" => ndouts,
  "error" => { "type" => "OperationOutcome",
               "url" => "http://serverpath2/err_file_1.ndjson" },
}
export = File.open("export/export.json", "w")
export.write(JSON.pretty_generate(output))

puts("Files written to /export")
