require 'socket'
require 'thread'
require_relative 'mime_type'
require_relative 'http_request'

NUMBER_OF_WORKER_THREADS = 1024
SERVER_ADDRESS = '0.0.0.0'
SERVER_PORT = 8080

connections_queue = Queue.new

server = TCPServer.new(SERVER_ADDRESS, SERVER_PORT)

workrs = (0...NUMBER_OF_WORKER_THREADS).map do
  Thread.new do
    loop do
      conn = connections_queue.pop

      request = conn.gets
      #puts request

      http_request = HTTPRequest.new(request)
      fiber = http_request.response

      while response = fiber.resume do
        conn.print response
      end

      conn.close
    end
  end
end

loop do
  connection = server.accept
  connections_queue << connection
end
