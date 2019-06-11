# frozen_string_literal: true

module Formulary
  # Handles configuration
  class Config
    def self.plan_urls
      raw_config['plan_urls']
    end

    def self.drug_urls
      raw_config['drug_urls']
    end

    def self.max_drugs_per_plan
      raw_config['max_drugs_per_plan']
    end

    def self.raw_config
      file_path = File.join(__dir__, '..', '..', 'config.yml')
      @raw_config ||= YAML.safe_load(File.read(file_path))
    end

    private_class_method :raw_config
  end
end
