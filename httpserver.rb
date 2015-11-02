require 'socket'

server = TCPServer.new(8080)

class HTTPRequest
  attr_reader :request_type, :filename, :protocol

  def initialize(request)
    @request_type, @filename, @protocol = request.split

    # TODO: sanitise and validate filename
    @filename = @filename.gsub(/\A\//, '')
  end

  def build_response
    response = ""

    begin
      response = response_headers

      case @request_type
      when 'HEAD'
        # Do nothing, HEAD just sends back headers
      when 'GET'
        # TODO: read binary file?
        file =  File.open(@filename, 'r')
        response += file.read
      end
    rescue => e
      response = "HTTP/1.0 404 Not Found\r\n\r\n"
    end

    response
  end

  private

  def response_headers
    if(File.exists?(@filename))
      response = "HTTP/1.0 200 OK\r\n"
      response += "Content-Type: text/plain\r\n"
      response +=  "\r\n"

      response
    else
      fail 'FileNotFound'
      #"HTTP/1.0 404 Not Found\r\n\r\n"
    end
  end
end


loop do
  client = server.accept
  request = client.gets
  puts request

  # GET /testfile.txt HTTP/1.0
  http_request = HTTPRequest.new(request)
  client.print http_request.build_response
  client.close
end

