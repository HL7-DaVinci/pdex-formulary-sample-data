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
        file_path = File.join(url,  '**/*.json')
        filenames = Dir.glob(file_path)
        puts "Reading #{filenames.length} file(s) from #{url}"

        filenames.each do |filename|
          qhp_raw_data = File.read(filename)
          qhp_json.concat(JSON.parse(qhp_raw_data, symbolize_names: true))
          repo.import(qhp_json)
        end
      end
    end

    def qhp_json
      @qhp_json ||= []
    end
  end
end
