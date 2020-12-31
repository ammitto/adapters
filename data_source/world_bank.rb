require_relative '../utils/processor'

module DataSource
  class WorldBank

    API_ENDPOINT = "https://apigwext.worldbank.org/dvsvc/v1.0/json/APPLICATION/ADOBE_EXPRNCE_MGR/FIRM/SANCTIONED_FIRM".freeze
    SOURCE = "world_bank".freeze
    API_KEY = "z9duUaFUiEUYSHs97CU38fcZO7ipOPvm".freeze

    def self.fetch(time)
      download_wb_json(time)
      Processor.convert_json_to_yaml(time, SOURCE)
      puts "Processed yml file is at:  ../data/processed/#{SOURCE}/#{time}/sanction_list.yaml !"
    end

    def self.download_wb_json(time)
      uri = URI.parse(API_ENDPOINT)
      request = Net::HTTP::Get.new(uri)
      request.content_type = "application/json"
      req_options = {use_ssl: uri.scheme == "https"}
      request['apikey'] = API_KEY
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      directory = "../data/downloaded/#{SOURCE}/#{time}"
      FileUtils.mkdir_p directory
      open("#{directory}/sanction_list.json", "wb") do |file|
        file.write(response.body)
      end
    end

  end
end

