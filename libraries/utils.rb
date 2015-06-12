require "net/http"
require "uri"
require "json"

module Utils

  MAX_RETRIES = 30
  SLEEP_TIME = 10.0

  def Utils.wait_until_url_available(url)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 600

    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    for i in 1..MAX_RETRIES
      begin
        request = Net::HTTP::Get.new(uri.request_uri)
        request.add_field("Accept-Language", "en-US")
        response = http.request(request)

        if response.code.to_i < 400
          Chef::Log.info("URL #{url} is available.")
          break
        end

        Chef::Log.debug("URL #{url} is not yet available. HTTP response code = #{response.code} (#{response.message})")
      rescue Exception => ex
        Chef::Log.debug("URL #{url} is not yet available. #{ex.message}")
      end

      sleep(SLEEP_TIME)
    end 
  end
  
  def Utils.load_properties(properties_filename)
    properties = {}
    File.open(properties_filename, 'r') do |properties_file|
      properties_file.read.each_line do |line|
        line.strip!
        if (line[0] != ?# and line[0] != ?=)
          i = line.index('=')
          if (i)
            properties[line[0..i - 1].strip] = line[i + 1..-1].strip
          else
            properties[line] = ''
          end
        end
      end      
    end
    properties
  end
  
end
