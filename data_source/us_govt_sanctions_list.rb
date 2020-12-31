require_relative '../utils/processor'
module DataSource
  class UsGovtSanctionsList

    API_ENDPOINT = "https://www.treasury.gov/ofac/downloads/sanctions/1.0/sdn_advanced.xml".freeze
    SOURCE = "us_govt_sanctions_list".freeze

    def self.fetch(time)
      Processor.download_xml(time, API_ENDPOINT, SOURCE)
      Processor.convert_to_yaml(time, SOURCE)
      puts "Processed yml file is at:  ../data/processed/#{SOURCE}/#{time}/sanction_list.yaml !"
    end

  end
end

