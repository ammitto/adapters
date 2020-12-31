class Processor

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
    open("#{directory}/sanction_list.xml", "wb") do |file|
      file.write(response.body)
    end
  end

  def self.convert_to_yaml(time, source)
    src_directory = "../data/downloaded/#{source}/#{time}"
    dest_directory = "../data/processed/#{source}/#{time}"
    FileUtils.mkdir_p dest_directory
    file = open("#{src_directory}/sanction_list.xml", "r")
    hash = Hash.from_xml(file.read)
    yaml = hash.to_yaml
    open("#{dest_directory}/sanction_list.yaml", "w") { |file| file.write(yaml) }
  end

  def self.convert_json_to_yaml(time, source)
    src_directory = "../data/downloaded/#{source}/#{time}"
    dest_directory = "../data/processed/#{source}/#{time}"
    FileUtils.mkdir_p dest_directory
    file = open("#{src_directory}/sanction_list.json", "r")
    yaml = JSON.parse(file.read).to_yaml
    open("#{dest_directory}/sanction_list.yaml", "w") { |file| file.write(yaml) }
  end

end