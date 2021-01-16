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

end