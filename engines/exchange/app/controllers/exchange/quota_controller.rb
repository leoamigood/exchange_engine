module Exchange
  class QuotaController < ApplicationController
    def index
      @quota = Exchange::Service.quota
    end
  end
end
