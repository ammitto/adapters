require 'net/http'
require 'active_support/core_ext/hash/conversions'
require 'yaml'
require 'fileutils'
require 'json'
require 'nokogiri'
require 'require_all'
require_all 'data_source'

time = Time.now.strftime("%d-%m-%Y-%H:%M:%S")
DataSource.constants.each do |klass|
  "DataSource::#{klass}".constantize.fetch(time)
end
puts "Done at #{time}!"

