require "exchange/version"
require "exchange/engine"

module Exchange
  class Service
    QUOTA_REFRESH = 30.seconds
    QUOTA_TTL = 60.seconds

    class << self
      def get_quota(ws)
        Rails.logger.debug "Getting quota. Quota will expire at #{Time.now + QUOTA_TTL}"
        ws.send(rand(100))
      end

      def save_quota(event, expires_in: QUOTA_TTL)
        Exchange::Redis.client.set("exchange_quota", event.data, ex: expires_in)
      end

      def quota
        Exchange::Redis.client.get('exchange_quota') || "Expired/Not available"
      end

      def trace
        url = Exchange::Engine.routes.url_for(host: 'localhost:3000', action: 'index', controller: 'exchange/quota')
        Rails.logger.debug "#{Time.now}: Quota: #{quota}, #{url}"
      end
    end
  end

  class Redis
    class << self
      def client
        @redis ||= ConnectionPool::Wrapper.new do
          ::Redis.new(url: ENV.fetch("REDIS_URL") { "redis://localhost:6379" })
        end
      end
    end
  end
end
