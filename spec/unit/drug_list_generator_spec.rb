# frozen_string_literal: true

require 'digest'
require_relative '../../lib/formulary/drug_list_generator'

RSpec.describe Formulary::DrugListGenerator do
  let(:raw_plans) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_plans.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:raw_plan) { raw_plans.first }

  let(:plan) do
    Formulary::QHPPlan.new(raw_plan)
  end

  let(:raw_drugs) do
    fixture_path = File.join(__dir__, '..', 'fixtures', 'qhp_drugs.json')
    JSON.parse(File.read(fixture_path), symbolize_names: true)
  end

  let(:repo) do
    Formulary::QHPDrugRepo
  end

  let(:output_directory) { File.join(__dir__, '..', '..', 'tmp', 'spec_output') }
  let(:name_prefix) { generator.id_prefix }
  let(:list_path) { File.join(output_directory, "#{name_prefix}.List.entry.json") }

  let(:generator) { Formulary::DrugListGenerator.new(plan) }

  before(:each) do
    FileUtils.rm_rf(output_directory)
    repo.import(raw_drugs)
    allow_any_instance_of(Formulary::DrugListGenerator)
      .to receive(:base_output_directory).and_return(output_directory)
  end

  after(:each) do
    repo.reset!
  end

  describe '#generate' do
    it 'creates a list of drug references' do
      generator.generate
      output = JSON.parse(File.read(list_path))
      expect(output.length).to eq(raw_drugs.length)
    end

    it 'creates MedicationKnowledge resources' do
      generator.generate
      list = JSON.parse(File.read(list_path), symbolize_names: true)
      ids = list.map { |entry| entry[:item][:reference].split('/').last }
      resource_directory = File.join(output_directory, name_prefix)
      ids.each do |id|
        file_name = "#{id}.MedicationKnowledge.json"
        json = JSON.parse(File.read(File.join(resource_directory, file_name)))
        resource = FHIR::MedicationKnowledge.new(json)
        expect(resource).to be_valid
      end
    end
  end
end
