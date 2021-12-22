require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  get '/pricing' => 'welcome#pricing'
  get '/pricing_iframe' => 'welcome#pricing_iframe'
  post '/ingest' => 'welcome#log'
  get '/search' => 'dashboard#search'
  
  get '/start' => redirect('/users/sign_up')
  get '/login' => redirect('/users/sign_in')

  get '/privacy' => 'welcome#privacy'
  get '/terms' => 'welcome#terms'

  mount Sidekiq::Web => '/sidekiq'

  devise_for :users, :controllers => {
    :omniauth_callbacks => 'users/omniauth_callbacks',
    :registrations => 'registrations',
    :sessions => 'sessions',
  }

  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end
  root 'welcome#index'
end
