require 'faye/websocket'
require 'eventmachine'

Thread.new do
  EM.run {
    @ws = Faye::WebSocket::Client.new('ws://ws.vi-server.org/mirror')

    @ws.on :open do |event|
      p [:open]

      puts "Connection established."
    end

    @ws.on :message do |event|
      p [:message]

      puts "Received message: #{event.data}"
    end

    @ws.on :close do |event|
      p [:close, event.code, event.reason]
      @ws = nil
    end
  }
end

EM.next_tick do
  EM.add_periodic_timer(10) do
    msg = "periodic message"
    puts "Sending #{msg}..."

    @ws.send(msg)
  end
end
