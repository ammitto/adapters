require 'net/http'
require 'active_support/core_ext/hash/conversions'
require 'yaml'
require 'fileutils'
require 'json'
require 'nokogiri'
require 'require_all'
require_all 'data_source'
require_all 'utils'

repo_to_update = Dir.glob('../*-data')
                   .map{|entry| "#{File.basename(entry)
                   .sub("-data", "").split("-")
                   .map(&:capitalize).join("")}Extractor" }
DataSource.constants.select { |klass| repo_to_update.include?(klass.to_s) }.each do |klass|
  "DataSource::#{klass}".constantize.fetch
end
puts "Done at #{Time.now.strftime("%d-%m-%Y-%H:%M:%S")}!"
