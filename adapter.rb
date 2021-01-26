require 'net/http'
require 'active_support/core_ext/hash/conversions'
require 'yaml'
require 'fileutils'
require 'json'
require 'nokogiri'
require 'require_all'
require_all 'data_source'
require_all 'utils'

time = Time.now.strftime("%d-%m-%Y-%H:%M:%S")
log_file = "../data/update.log"

DataSource.constants.each do |klass|
  "DataSource::#{klass}".constantize.fetch
end

Processor.file_prepend(log_file, "Updated at : #{time}\n")
puts "Done at #{time}!"
