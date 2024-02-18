Rails.application.routes.draw do
  mount Exchange::Engine => "/exchange"
end
