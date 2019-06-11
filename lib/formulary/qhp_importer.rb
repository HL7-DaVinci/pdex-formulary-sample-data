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
        qhp_raw_data = HTTParty.get(url, verify: false) # FIXME
        qhp_json.concat(JSON.parse(qhp_raw_data, symbolize_names: true))
      end
      repo.import(qhp_json)
    end

    def qhp_json
      @qhp_json ||= []
    end
  end
end
