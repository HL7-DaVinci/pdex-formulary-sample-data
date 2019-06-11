module Formulary
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

    private

    def self.raw_config
      file_path = File.join(__dir__, '..', '..', 'config.yml')
      @config ||= YAML.load(File.read(file_path))
    end
  end
end
