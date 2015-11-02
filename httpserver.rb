require 'socket'
require_relative 'mime_type'

server = TCPServer.new(8080)

class HTTPRequest
  attr_reader :request_type, :file_path, :protocol

  def initialize(request)
    @request_type, @file_path, @protocol = request.split

    # TODO: sanitise and validate file_path
    @file_path = @file_path.gsub(/\A\//, '')

    unless File.file?(@file_path)
      @file_path += "/index.html" if File.file?(@file_path + "/index.html")
    end
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
        file =  File.open(@file_path, 'r')
        response += file.read
      end
    rescue => e
      response = "HTTP/1.0 404 Not Found\r\n\r\n"
    end

    response
  end

  private

  def response_headers
    if(File.file?(@file_path))
      response = "HTTP/1.0 200 OK\r\n"
      response += "Content-Type: #{MimeType.from_file(@file_path)}\r\n"
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

