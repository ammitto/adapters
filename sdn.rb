require 'bundler/inline'
require 'net/http'
require 'active_support/core_ext/hash/conversions'
require 'yaml'
require 'fileutils'

gemfile do
  source 'https://rubygems.org'
  gem 'activesupport'
  gem 'yaml'
end

class Sdn

  def self.download_xml(time, url, source)
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/xml"
    req_options = {use_ssl: uri.scheme == "https"}
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    directory = "../data/downloaded/#{source}/#{time}"
    FileUtils.mkdir_p directory
    open("#{directory}/sdn.xml", "wb") do |file|
      file.write(response.body)
    end
  end

  def self.convert_to_yaml(time, source)
    src_directory = "../data/downloaded/#{source}/#{time}"
    dest_directory = "../data/processed/#{source}/#{time}"
    FileUtils.mkdir_p dest_directory
    file = open("#{src_directory}/sdn.xml", "r")
    hash = Hash.from_xml(file.read)
    yaml = hash.to_yaml
    open("#{dest_directory}/sdn.yaml", "w") { |file| file.write(yaml) }
  end

end

time = Time.now.strftime("%d-%m-%Y-%H:%M:%S")
url = "https://www.treasury.gov/ofac/downloads/sanctions/1.0/sdn_advanced.xml"
source = 'us'
Sdn.download_xml(time, url, source)
Sdn.convert_to_yaml(time, source)

puts "Done at #{time}!"
puts "Processed yml file is at:  ../data/processed/#{source}/#{time}/sdn.yaml !"
