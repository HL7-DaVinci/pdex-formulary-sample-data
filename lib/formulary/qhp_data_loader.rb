require 'httparty'

module Formulary
  class QHPPlanImporter
    def initialize(urls)
      @urls = urls
    end

    def import
      @urls.each do |url|
        raw_plans = HTTParty.get(url, verify: false) # FIXME
        json_plans = JSON.parse(raw_plans, symbolize_names: true)
        plans.concat(json_plans)
      end
      plans
    end

    def plans
      @plans ||= []
    end
  end
end
