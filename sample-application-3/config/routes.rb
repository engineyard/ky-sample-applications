require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]



Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount Sidekiq::Web => '/sidekiq'
  resources :pages, :defaults => { :format => :json }
  #get '/metrics', to: 'pages#metrics'
    
  #require 'sidekiq/prometheus/exporter'
  #mount Sidekiq::Prometheus::Exporter => '/metrics'

end
