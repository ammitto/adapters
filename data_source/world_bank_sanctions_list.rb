module DataSource
  class WorldBankSanctionsList

    API_ENDPOINT = "https://apigwext.worldbank.org/dvsvc/v1.0/json/APPLICATION/ADOBE_EXPRNCE_MGR/FIRM/SANCTIONED_FIRM".freeze
    SOURCE = "world_bank".freeze
    API_KEY = "z9duUaFUiEUYSHs97CU38fcZO7ipOPvm".freeze

    def self.fetch
      download_wb_json
      harmonize
      puts "Processed yml file is at:  ../data/processed/#{SOURCE}.yaml !"
    end

    def self.download_wb_json
      uri = URI.parse(API_ENDPOINT)
      request = Net::HTTP::Get.new(uri)
      request.content_type = "application/json"
      req_options = {use_ssl: uri.scheme == "https"}
      request['apikey'] = API_KEY
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      directory = "../data/downloaded"
      FileUtils.mkdir_p directory
      open("#{directory}/#{SOURCE}.json", "wb") do |file|
        file.write(response.body)
      end
    end

    def self.harmonize
      downloaded_directory = "../data/downloaded"
      dest_directory = "../data/processed"
      processed_data = []
      data = JSON.parse(File.read("#{downloaded_directory}/#{SOURCE}.json"))
      data["response"]["ZPROCSUPP"].each do |sanction_entity|
        target = {}
        target["names"] = "#{sanction_entity["SUPP_PRE_ACRN"]} #{sanction_entity["SUPP_NAME"]}".strip
        target["country"] = sanction_entity["COUNTRY_NAME"]
        target["source"] = SOURCE
        target["ref_number"] = sanction_entity["SUPP_ID"]
        target["ref_type"] = "World Bank SUPP ID"
        target["remark"] = sanction_entity["DEBAR_REASON"]
        address = {}
        address["street"] = sanction_entity["SUPP_ADDR"]
        address["city"] = sanction_entity["SUPP_CITY"]
        address["state"] = sanction_entity["SUPP_PROV_NAME"]
        address["country"] = sanction_entity["COUNTRY_NAME"]
        address["zip"] = sanction_entity["SUPP_ZIP_CODE"] || sanction_entity["SUPP_POST_CODE"]
        target["address"] = [ address ]
        processed_data << target
      end

      FileUtils.mkdir_p dest_directory
      open("#{dest_directory}/#{SOURCE}.yaml", "w") { |file| file.write(processed_data.to_yaml) }
    end

  end
end

