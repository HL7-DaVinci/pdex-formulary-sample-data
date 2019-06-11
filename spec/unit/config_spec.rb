# frozen_string_literal: true

require_relative '../../lib/formulary/config'

RSpec.describe Formulary::Config do
  before(:all) do
    file_path = File.join(__dir__, '..', '..', 'config.yml')
    @config ||= YAML.safe_load(File.read(file_path))
  end

  describe '.plan_urls' do
    it 'returns the plan urls from config.yml' do
      expect(Formulary::Config.plan_urls).to eq(@config['plan_urls'])
    end
  end

  describe '.drug_urls' do
    it 'returns the drug urls from config.yml' do
      expect(Formulary::Config.drug_urls).to eq(@config['drug_urls'])
    end
  end

  describe '.max_drugs_per_plan' do
    it 'returns the max drugs per plan from config.yml' do
      expect(Formulary::Config.max_drugs_per_plan).to eq(@config['max_drugs_per_plan'])
    end
  end
end
