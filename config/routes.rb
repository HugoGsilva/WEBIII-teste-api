Rails.application.routes.draw do
  # Mount Rswag UI for API documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API v1 namespace
  namespace :api do
    namespace :v1 do
      resources :produtos
      resources :pedidos
      get 'enderecos/:cep', to: 'enderecos#show'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
