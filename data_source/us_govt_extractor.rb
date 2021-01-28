module DataSource
  class UsGovtExtractor

    API_ENDPOINT = "https://www.treasury.gov/ofac/downloads/consolidated/consolidated.xml".freeze
    SOURCE = "us-govt-data".freeze

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
      sanctions = data.xpath("sdnList//sdnEntry")
      sanctions.each do |sanction|
        target = {}
        name = [sanction.at_xpath("firstName"),
                sanction.at_xpath("lastName")].compact.map(&:text).reject(&:blank?).map(&:strip).join(" ")
        alias_names = sanction.xpath("akaList//aka").map { |aka| [aka.at_xpath("firstName"), aka.at_xpath("lastName")].join(" ") }.reject(&:blank?)
        target["entity_type"] = sanction.at_xpath("sdnType") == "Individual" ? "person" : "organization"
        target["names"] = alias_names
        target["names"].unshift(name)
        target["source"] = SOURCE
        target["ref_number"] = sanction.at_xpath("uid")&.text
        target["ref_type"] = "Sdn UID"
        target["country"] = sanction.at_xpath("addressList//address//country")&.text
        target["birthdate"] = sanction.at_xpath("dateOfBirthList//dateOfBirthItem//dateOfBirth")&.text
        target["remark"] = sanction.at_xpath("remarks")&.text&.strip
        addresses = []
        sanction.xpath("addressList//address").each do |ads|
          addrs = {}
          addrs["street"] =[ ads.at_xpath("address1")&.text,
                             ads.at_xpath("address2")&.text,
                             ads.at_xpath("address3")&.text,
                             ads.at_xpath("address4")&.text ].join(" ")
          addrs["city"] = ads.at_xpath("city")&.text
          addrs["state"] = ads.at_xpath("stateOrProvince")&.text
          addrs["country"] = ads.at_xpath("country")&.text
          addrs["zip"] = ads.at_xpath("postalCode")&.text
          addresses << addrs
        end
        target["address"] = addresses
        documents = []
        sanction.xpath("idList//id").each do |document|
          doc = {}
          doc["type"] = document.at_xpath("idType")&.text
          doc["number"] = document.at_xpath("idNumber")&.text
          doc["country"] = document.at_xpath("idCountry")&.text
          documents << doc
        end
        target["documents"] = documents
        processed_data << target
      end

      FileUtils.mkdir_p dest_directory
      open("#{dest_directory}/sanction_list.yaml", "w") { |file| file.write(processed_data.to_yaml) }
    end

  end
end

