require 'faye/websocket'
require 'eventmachine'

Thread.new do
  EM.run {
    @ws = Faye::WebSocket::Client.new('ws://ws.vi-server.org/mirror')

    @ws.on :open do |event|
      Rails.logger.debug "Exchange server connection established."
      Exchange::Service.get_quota(@ws)
    end

    @ws.on :message do |event|
      Exchange::Service.save_quota(event, expires_in: Exchange::Service::QUOTA_TTL)
    end

    @ws.on :close do |event|
      p [:close, event.code, event.reason]
      @ws = nil
    end
  }
end

EM.next_tick do
  EM.add_periodic_timer(5) do
    Exchange::Service.trace
  end

  EM.add_periodic_timer(Exchange::Service::QUOTA_REFRESH) do
    Exchange::Service.get_quota(@ws)
  end
end
