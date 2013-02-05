CustomSsoProvider::Application.routes.draw do
  use_doorkeeper

  root :to => 'pages#home'

  devise_for :stores

  # Customer Namespace
  #-----------------------------------------------------------------
  devise_for :customers, :path => 'customer', :controllers => {
    :confirmations => 'customer/confirmations',
    :passwords => 'customer/passwords',
    :registrations => 'customer/registrations',
    :sessions => 'customer/sessions',
    :unlocks => 'customer/unlocks'
  }
  namespace :customer do
    root :to                  => "home#index", :as => :home

    resources :payment_profiles, :path => "payment_methods", :except => [:show, :delete]
  end
end