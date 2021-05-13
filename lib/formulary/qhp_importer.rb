# frozen_string_literal: true

require 'httparty'

module Formulary
  # This class reads QHP data from a list of urls and loads it into a repository
  class QHPImporter
    attr_reader :urls, :repo

    def initialize(urls, repo)
      @urls = urls
      @repo = repo
    end

    def import
      urls.each do |url|
        if url.start_with?("http") then
          qhp_raw_data = HTTParty.get(url, verify: false) # FIXME
        else
          qhp_raw_data = File.read(url)
        end
        qhp_json.concat(JSON.parse(qhp_raw_data, symbolize_names: true))
      end
      repo.import(qhp_json)
    end

    def qhp_json
      @qhp_json ||= []
    end
  end
end
