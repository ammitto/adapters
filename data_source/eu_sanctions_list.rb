require_relative '../utils/processor'

module DataSource
  class EuSanctionsList

    API_ENDPOINT = "https://webgate.ec.europa.eu/fsd/fsf/public/files/xmlFullSanctionsList_1_1/content?token=dG9rZW4tMjAxNw".freeze
    SOURCE = "eu_sanctions_list".freeze

    def self.fetch(time)
      Processor.download_xml(time, API_ENDPOINT, SOURCE)
      harmonize(time)
      puts "Processed yml file is at:  ../data/processed/#{SOURCE}/#{time}/processed.yaml !"
    end

    def self.harmonize(time)
      downloaded_directory = "../data/downloaded/#{SOURCE}/#{time}"
      dest_directory = "../data/processed/#{SOURCE}/#{time}"
      processed_data = []
      data = Nokogiri.XML(open("#{downloaded_directory}/sanction_list.xml"))
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
      open("#{dest_directory}/processed.yaml", "w") { |file| file.write(processed_data.to_yaml) }
    end

    ######################################## DATA MODEL ##########################################
    # Names
    # Gender
    # Address
    #  - Street
    #  - Zip
    #  - City
    #  - State
    #  - Country
    # Contact
    # BirthDate
    # EntityType
    # IdentityType
    # IdentityNumber
    # Remark
    ######################################## DATA MODEL ##########################################

  end
end

