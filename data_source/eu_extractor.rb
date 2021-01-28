module DataSource
  class EuExtractor

    API_ENDPOINT = "https://webgate.ec.europa.eu/fsd/fsf/public/files/xmlFullSanctionsList_1_1/content?token=dG9rZW4tMjAxNw".freeze
    SOURCE = "eu-data".freeze

    def self.fetch
      Processor.download_xml(API_ENDPOINT, SOURCE, "../#{SOURCE}/downloaded")
      harmonize
      puts "Processed yml file is at:  ../#{SOURCE}/processed !"
      Processor.file_prepend("../#{SOURCE}/update.log", "Updated at : #{Time.now.strftime("%d-%m-%Y-%H:%M:%S")}\n")
    end

    def self.harmonize
      downloaded_directory = "../#{SOURCE}/downloaded"
      dest_directory = "../#{SOURCE}/processed"
      processed_data = []
      data = Nokogiri.XML(open("#{downloaded_directory}/#{SOURCE}.xml"))
      data.remove_namespaces!
      sanction_entities = data.xpath("export//sanctionEntity")
      sanction_entities.each do |sanction_entity|
        target = {}
        target["names"] = sanction_entity.xpath("nameAlias").collect { |n| n["wholeName"] } rescue ""
        target["source"] = SOURCE
        target["entity_type"] = sanction_entity.at_xpath("subjectType")["code"] == "enterprise" ? "organization" : "person" rescue ""
        target["country"] = sanction_entity.at_xpath("citizenship")["countryDescription"] rescue ""
        target["birthdate"] = sanction_entity.at_xpath("birthdate")["birthdate"] rescue ""
        target["ref_number"] = sanction_entity["euReferenceNumber"] rescue ""
        target["ref_type"] = "EU Reference Number"
        target["remark"] = sanction_entity["remark"] rescue ""
        unless sanction_entity.at_xpath("address").nil?
          address = {}
          address_info = sanction_entity.at_xpath("address")
          address["street"] = address_info["street"]
          address["city"] = address_info["city"]
          address["state"] = address_info["region"]
          address["country"] = address_info["countryDescription"]
          address["zip"] = address_info["zipCode"]
          po_box = address_info["poBox"]
          address["zip"] = "PO Box #{po_box}" if (address["zip"].empty? && !po_box.empty?)
          target["contact"] = address_info.xpath("contactInfo").collect { |ci| "#{ci['key']}: #{ci['value']}" }.join(", ") rescue ""
          target["address"] = [address]
        end
        processed_data << target
      end

      FileUtils.mkdir_p dest_directory
      open("#{dest_directory}/sanction_list.yaml", "w") { |file| file.write(processed_data.to_yaml) }
    end
  end

end

