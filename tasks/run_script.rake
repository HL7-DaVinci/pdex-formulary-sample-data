namespace :run_script do
  desc "Generate sample data"
  task :generate_data do
    ruby "scripts/generate.rb"
  end

  desc "Upload sample data to a server: can specify a fhir server, or a conformance url, or both"
  task :upload_to_server, [:fhir_server, :conformance_url] do |t, args|
    options = ""
    options << "-f #{args.fhir_server} " if args.fhir_server
    options << "-c #{args.conformance_url}" if args.conformance_url

    ruby "scripts/upload.rb #{options}"
  end

  desc "Generate bulk FHIR (ndjson) files"
  task :generate_ndjon do
    ruby "scripts/convertNDJSON.rb"
  end

  desc "Generate plan specific bulk FHIR (ndjson) files"
  task :plan_specific_ndjson do
    ruby "scripts/plan_specific_ndjson.rb"
  end
end
