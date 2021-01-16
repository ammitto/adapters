require_relative '../utils/processor'

module DataSource
  class UnSanctionsList

    API_ENDPOINT = "https://scsanctions.un.org/resources/xml/en/consolidated.xml".freeze
    SOURCE = "un_sanctions_list".freeze

    def self.fetch(time)
      Processor.download_xml(time, API_ENDPOINT, SOURCE)
      harmonize(time)
      puts "Processed yml file is at:  ../data/processed/#{SOURCE}/#{time}/sanction_list.yaml !"
    end

    def self.harmonize(time)
      downloaded_directory = "../data/downloaded/#{SOURCE}/#{time}"
      dest_directory = "../data/processed/#{SOURCE}/#{time}"
      processed_data = []
      data = Nokogiri.XML(open("#{downloaded_directory}/sanction_list.xml"))
      data.remove_namespaces!
      sanctions = data.xpath("CONSOLIDATED_LIST//INDIVIDUALS//INDIVIDUAL | CONSOLIDATED_LIST//ENTITIES//ENTITY")
      sanctions.each do |sanction|
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
        processed_data << target
      end

      FileUtils.mkdir_p dest_directory
      open("#{dest_directory}/processed.yaml", "w") { |file| file.write(processed_data.to_yaml) }
    end

  end
end

