module Exchange
  class QuotaController < ApplicationController
    def index
      @quota = Exchange::Service.quota
      @status = Exchange::Service.status
    end

    def pause
      Exchange::Service.pause!
      redirect_to quota_path
    end

    def resume
      Exchange::Service.resume!
      redirect_to quota_path
    end
  end
end
