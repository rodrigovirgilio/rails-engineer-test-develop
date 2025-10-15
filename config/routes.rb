Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "companies#index"

  resources :companies, only: :index

  namespace :admin do
    resources :companies, only: :index do
      collection do
        post :import
        delete :destroy_all
      end
    end
  end
end
