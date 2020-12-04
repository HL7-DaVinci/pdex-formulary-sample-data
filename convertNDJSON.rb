require 'json'
require 'pry'
    indir = ARGV[0]   # point to output directory
# First output the *List*.json, these are the CoveragePlan profile instances
puts "working on input directory: #{indir}..."
outfile = "CoveragePlan.ndjson"
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
        puts "working on input directory: #{plandir}..."
        outfile = "FormularyDrug_#{File.basename(plandir)}.ndjson"
        puts "writing to #{outfile}"
        o = File.open(outfile,"w")
        Dir.glob("#{plandir}/*.json") do |jsonfile|
            puts "working on: #{jsonfile}..."
            s = File.read(jsonfile)
            h = JSON.parse(s)
            o.puts(JSON.generate(h))
        end
        o.close
    end