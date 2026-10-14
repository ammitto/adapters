require 'tmpdir'
require 'fileutils'
require 'yaml'
require 'nokogiri'
require 'active_support/core_ext/object/blank'
require_relative '../utils/processor'
require_relative '../data_source/us_govt_extractor'

Dir.mktmpdir('ammitto-adapter-regression-') do |temporary|
  adapter_directory = File.join(temporary, 'adapter')
  source_directory = File.join(temporary, 'us-govt-data')
  FileUtils.mkdir_p(adapter_directory)
  FileUtils.mkdir_p(File.join(source_directory, 'downloaded'))
  File.write(File.join(source_directory, 'downloaded', 'us-govt-data.xml'), <<~XML)
    <sdnList xmlns="https://example.test/ofac">
      <sdnEntry><uid>1</uid><firstName>Jane</firstName><lastName>Doe</lastName><sdnType>Individual</sdnType></sdnEntry>
      <sdnEntry><uid>2</uid><lastName>Example Company</lastName><sdnType>Entity</sdnType></sdnEntry>
    </sdnList>
  XML
  Dir.chdir(adapter_directory) { DataSource::UsGovtExtractor.harmonize }
  records = Dir.glob(File.join(source_directory, 'processed', '*.yaml')).map do |file|
    YAML.safe_load(File.read(file))
  end
  raise "Expected two records, got #{records.length}" unless records.length == 2
  person = records.find { |record| record['ref_number'] == '1' }
  organization = records.find { |record| record['ref_number'] == '2' }
  raise 'Individual was not preserved as a person' unless person && person['entity_type'] == 'person' && person['names'] == ['Jane Doe']
  raise 'Entity was not preserved as an organization' unless organization && organization['entity_type'] == 'organization' && organization['names'] == ['Example Company']
end
puts 'US person and organization extraction passed'
