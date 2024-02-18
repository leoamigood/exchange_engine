Exchange::Engine.routes.draw do
  resources :quota, only: :index
end
