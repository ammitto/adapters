require_relative '../utils/processor'

module DataSource
  class EuSanctionsList

    API_ENDPOINT = "https://webgate.ec.europa.eu/fsd/fsf/public/files/xmlFullSanctionsList_1_1/content?token=dG9rZW4tMjAxNw".freeze
    SOURCE = "eu_sanctions_list".freeze

    def self.fetch(time)
      Processor.download_xml(time, API_ENDPOINT, SOURCE)
      Processor.convert_to_yaml(time, SOURCE)
      puts "Processed yml file is at:  ../data/processed/#{SOURCE}/#{time}/sanction_list.yaml !"
    end

  end
end

