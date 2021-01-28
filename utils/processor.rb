class Processor

  def self.download_xml(url, source, directory)
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/xml"
    req_options = {use_ssl: uri.scheme == "https"}
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    FileUtils.mkdir_p directory
    open("#{directory}/#{source}.xml", "wb") do |file|
      file.write(response.body)
    end
  end

  def self.file_prepend(file, str)
    new_contents = ""
    File.open(file, 'r') do |fd|
      contents = fd.read
      new_contents = str << contents
    end
    File.open(file, 'w') do |fd|
      fd.write(new_contents)
    end
  end

end