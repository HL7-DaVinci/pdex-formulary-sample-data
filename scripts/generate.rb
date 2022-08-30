# frozen_string_literal: true

require "pry"
require "fileutils"
require_relative "../lib/formulary/config"
require_relative "../lib/formulary/drug_list_generator"
require_relative "../lib/formulary/qhp_drug_repo"
require_relative "../lib/formulary/qhp_importer"
require_relative "../lib/formulary/qhp_plan_repo"

# Delete the output directory if it exists.
FileUtils.rm_rf("output")
puts "Starting Formulary data generation..."

config = Formulary::Config
drug_repo = Formulary::QHPDrugRepo
plan_repo = Formulary::QHPPlanRepo

Formulary::QHPImporter
  .new(config.plan_urls, plan_repo)
  .import
Formulary::QHPImporter
  .new(config.drug_urls, drug_repo)
  .import

plan_repo.all.each do |plan|
  Formulary::DrugListGenerator.new(plan).generate
end

puts "Data Generation completed!!!"
