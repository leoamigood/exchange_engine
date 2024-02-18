Exchange::Engine.routes.draw do
  resources :quota, only: :index do
    collection do
      get :pause
      get :resume
    end
  end
end
