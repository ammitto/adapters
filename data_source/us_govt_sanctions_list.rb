require_relative '../utils/processor'

module DataSource
  class UsGovtSanctionsList

    API_ENDPOINT = "https://www.treasury.gov/ofac/downloads/consolidated/consolidated.xml".freeze
    SOURCE = "us_govt_sanctions_list".freeze

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
      open("#{dest_directory}/processed.yaml", "w") { |file| file.write(processed_data.to_yaml) }
    end

  end
end

