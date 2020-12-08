require 'json'
require 'pry'
    indir = ARGV[0]   # point to output directory
# First output the *List*.json, these are the CoveragePlan profile instances
puts "working on input directory: #{indir}..."
outfile = "CoveragePlan.ndjson"
ndouts = []
ndouts << {
    "type" => "List",
    "url" => outfile
}
puts "writing to #{outfile}"
    o = File.open(outfile,"w")
    Dir.glob("#{indir}/*.json") do |jsonfile|
        puts "working on: #{jsonfile}..."
        s = File.read(jsonfile)
        h = JSON.parse(s)
        o.puts(JSON.generate(h))
    end
    o.close
# Next iterate through the directories, each one contains the MedicationKnowledge profile instances for a single plan
    Dir.glob("#{indir}/*/") do |plandir|
        # puts "working on input directory: #{plandir}..."
        outfile = "FormularyDrug_#{File.basename(plandir)}.ndjson"
        puts "writing to #{outfile}"
        ndouts << {
            "type" => "MedicationKnowledge",
            "url" => outfile
        }
        o = File.open(outfile,"w")
        Dir.glob("#{plandir}/*.json") do |jsonfile|
            # puts "working on: #{jsonfile}..."
            s = File.read(jsonfile)
            h = JSON.parse(s)
            o.puts(JSON.generate(h))
        end
        o.close
    end
    output = {
        "transactionTime" => Time.now.strftime("%d/%m/%Y %H:%M"),
        "request" => "<baseFhirURL>/$export",
        "requiresAccessToken" => false,
        "output" => ndouts,
        "error" => { "type" => "OperationOutcome",
                    "url" =>  "http://serverpath2/err_file_1.ndjson"}
    }
    export = File.open("export.json","w")
    export.write(JSON.pretty_generate(output))