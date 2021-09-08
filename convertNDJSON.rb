
require 'json'
require 'pry'


# FHIR_SERVER_BASE = "http://localhost:8080/plan-net"
FHIR_SERVER_BASE = "https://davinci-drug-formulary-ri.logicahealth.org/fhir"
    
ndouts = []
FileUtils.mkdir_p("export/")
Dir.glob("output/*/") do |typedir|
    puts "working on input directory: #{typedir}..."
    resourceType = File.basename(typedir)
    url = "#{FHIR_SERVER_BASE}/resources/#{resourceType}.ndjson"
    ndouts << {
        "type" => resourceType,
        "url" => url
    }
    outfile = "export/#{resourceType}.ndjson"
    puts "writing to #{outfile}"
    o = File.open(outfile,"w")
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
                "url" =>  "http://serverpath2/err_file_1.ndjson"}
}
export = File.open("export/export.json","w")
export.write(JSON.pretty_generate(output))
puts("Files written to /export")




# STU1.0.0 code
#puts "working on input directory: output..."
#FileUtils.mkdir_p("export/")
#outfile = "CoveragePlan.ndjson"
#ndouts = []
#ndouts << {
#    "type" => "List",
#    "url" => "#{FHIR_SERVER_BASE}/resources/#{outfile}"
#}
#puts "writing to export/#{outfile}"
#    o = File.open("export/#{outfile}","w")
#    Dir.glob("output/*.json") do |jsonfile|
#        puts "working on: #{jsonfile}..."
#        s = File.read(jsonfile)
#        h = JSON.parse(s)
#        o.puts(JSON.generate(h))
#    end
#    o.close
    # Next iterate through the directories, each one contains the MedicationKnowledge profile instances for a single plan
#    Dir.glob("output/*/") do |plandir|
#        outfile = "FormularyDrug_#{File.basename(plandir)}.ndjson"
#        puts "writing to #{outfile}"
#        url = "#{FHIR_SERVER_BASE}/resources/#{outfile}"
#        ndouts << {
#            "type" => "MedicationKnowledge",
#            "url" => url
#        }
#        o = File.open("export/#{outfile}","w")
#        Dir.glob("#{plandir}/*.json") do |jsonfile|
#            s = File.read(jsonfile)
#            h = JSON.parse(s)
#            o.puts(JSON.generate(h))
#        end
#        o.close
#    end
#    output = {
#        "transactionTime" => Time.now.strftime("%d/%m/%Y %H:%M"),
#        "request" => "#{FHIR_SERVER_BASE}/fhir/$export",
#        "requiresAccessToken" => false,
#        "output" => ndouts,
#        "error" => { "type" => "OperationOutcome",
#                    "url" =>  "http://#{FHIR_SERVER_BASE}/resources/err_file_1.ndjson"}
#    }
#    export = File.open("export/export.json","w")
#    export.write(JSON.pretty_generate(output))
#    puts "Files written to /export"