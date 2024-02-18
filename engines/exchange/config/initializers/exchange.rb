require 'faye/websocket'
require 'eventmachine'

QUOTA_TTL = 7.seconds

Thread.new do
  EM.run {
    @ws = Faye::WebSocket::Client.new('ws://ws.vi-server.org/mirror')

    @ws.on :open do |event|
      p [:open]

      puts "Connection established."
      get_quota
    end

    @ws.on :message do |event|
      p [:message]

      save_quota(event, expires_in: 7)
    end

    @ws.on :close do |event|
      p [:close, event.code, event.reason]
      @ws = nil
    end
  }
end

EM.next_tick do
  EM.add_periodic_timer(3) do
    show_quota
  end

  EM.add_periodic_timer(16) do
    get_quota
  end
end

def redis
  @redis ||= ConnectionPool::Wrapper.new do
    Redis.new(url: ENV.fetch("REDIS_URL") { "redis://localhost:6379" })
  end
end

def get_quota
  puts "Getting quota. Expires at #{Time.now + QUOTA_TTL}"
  @ws.send(rand(100))
end

def save_quota(event, expires_in: QUOTA_TTL)
  redis.set("exchange_quota", event.data, ex: expires_in)
end

def show_quota
  puts "#{Time.now}: quota: #{redis.get('exchange_quota') || "Expired/Not available"}"
end
