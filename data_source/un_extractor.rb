module DataSource
  class UnExtractor

    API_ENDPOINT = "https://scsanctions.un.org/resources/xml/en/consolidated.xml".freeze
    SOURCE = "un-data".freeze

    def self.fetch
      Processor.download_xml(API_ENDPOINT, SOURCE, "../#{SOURCE}/downloaded")
      harmonize
      puts "Processed yml files are at:  ../#{SOURCE}/processed !"
      Processor.file_prepend("../#{SOURCE}/update.log", "Updated at : #{Time.now.strftime("%d-%m-%Y-%H:%M:%S")}\n")
    end

    def self.harmonize
      downloaded_directory = "../#{SOURCE}/downloaded"
      dest_directory = "../#{SOURCE}/processed"
      data = Nokogiri.XML(open("#{downloaded_directory}/#{SOURCE}.xml"))
      data.remove_namespaces!
      sanctions = data.xpath("CONSOLIDATED_LIST//INDIVIDUALS//INDIVIDUAL | CONSOLIDATED_LIST//ENTITIES//ENTITY")
      if sanctions.any?
        Processor.prepare_directory(dest_directory)
        sanctions.each_with_index do |sanction, index|
          target = {}
          name = [sanction.at_xpath("FIRST_NAME"),
                  sanction.at_xpath("SECOND_NAME"),
                  sanction.at_xpath("THIRD_NAME"),
                  sanction.at_xpath("FOURTH_NAME")].compact.map(&:text).reject(&:blank?).map(&:strip).join(" ")
          alias_names = sanction.xpath("INDIVIDUAL_ALIAS//ALIAS_NAME | ENTITY_ALIAS//ALIAS_NAME").map(&:text).reject(&:blank?)
          target["entity_type"] = sanction.parent.name == "INDIVIDUALS" ? "person" : "organization"
          target["names"] = alias_names
          target["names"].unshift(name)
          target["designation"] = sanction.at_xpath("DESIGNATION//VALUE")&.text
          target["source"] = SOURCE
          target["ref_number"] = sanction.at_xpath("REFERENCE_NUMBER")&.text&.strip
          target["ref_type"] = sanction.at_xpath("UN_LIST_TYPE")&.text
          target["country"] = sanction.at_xpath("NATIONALITY//VALUE")&.text
          target["birthdate"] = sanction.at_xpath("INDIVIDUAL_DATE_OF_BIRTH//DATE")&.text
          target["remark"] = sanction.at_xpath("COMMENTS1")&.text.strip
          addresses = []
          sanction.xpath("INDIVIDUAL_ADDRESS | ENTITY_ADDRESS").each do |ads|
            addrs = {}
            addrs["street"] = ads.at_xpath("STREET")&.text
            addrs["city"] = ads.at_xpath("CITY")&.text
            addrs["state"] = ads.at_xpath("STATE_PROVINCE")&.text
            addrs["country"] = ads.at_xpath("COUNTRY")&.text
            addrs["zip"] = ads.at_xpath("ZIP_CODE")&.text
            addresses << addrs
          end
          target["address"] = addresses
          documents = []
          sanction.xpath("INDIVIDUAL_DOCUMENT").each do |document|
            doc = {}
            doc["type"] = document.at_xpath("TYPE_OF_DOCUMENT")&.text
            doc["number"] = document.at_xpath("NUMBER")&.text
            doc["country"] = document.at_xpath("ISSUING_COUNTRY")&.text
            doc["note"] = document.at_xpath("NOTE")&.text
            documents << doc
          end
          target["documents"] = documents
          Processor.save_structured_data(dest_directory, target, index)
        end
      end
    end

  end
end

