require_relative '../utils/processor'

module DataSource
  class UnSanctionsList

    API_ENDPOINT = "https://scsanctions.un.org/resources/xml/en/consolidated.xml".freeze
    SOURCE = "un_sanctions_list".freeze

    def self.fetch(time)
      Processor.download_xml(time, API_ENDPOINT, SOURCE)
      Processor.convert_to_yaml(time, SOURCE)
      puts "Processed yml file is at:  ../data/processed/#{SOURCE}/#{time}/sanction_list.yaml !"
    end

  end
end

