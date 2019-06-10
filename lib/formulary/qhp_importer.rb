require 'httparty'

module Formulary
  class QHPImporter
    attr_reader :urls, :repo

    def initialize(urls, repo)
      @urls = urls
      @repo = repo
    end

    def import
      urls.each do |url|
        raw_plans = HTTParty.get(url, verify: false) # FIXME
        json_plans = JSON.parse(raw_plans, symbolize_names: true)
        plans.concat(json_plans)
      end
      repo.import(plans)
    end

    def plans
      @plans ||= []
    end
  end
end
