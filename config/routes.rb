Onering::Application.routes.draw do
  root :to              => "pages#home",             :as => :home

  # OmniAuth Provider paths
  #-----------------------------------------------------------------
  match '/oauth/authorize' => 'auth#authorize', :as => :authorization
  match '/oauth/access_token' => 'auth#access_token'
  match '/oauth/customer' => 'auth#customer'
#    match '/oauth/token' => 'auth#access_token'

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
    root :to                  => "pages#home", :as => :home
    resources :payment_profiles, :path => "payment_methods"

    # OmniAuth Provider paths
    #-----------------------------------------------------------------
#    match '/oauth/authorize' => 'auth#authorize', :as => :authorization
#    match '/oauth/access_token' => 'auth#access_token'
#    match '/oauth/customer' => 'auth#customer'
#    match '/oauth/token' => 'auth#access_token'
  end

  # Store Namespace
  #-----------------------------------------------------------------
  devise_for :stores, :path => 'store', :controllers => {
    :confirmations => 'store/confirmations',
    :passwords => 'store/passwords',
    :registrations => 'store/registrations',
    :sessions => 'store/sessions',
    :unlocks => 'store/unlocks'
  }

  namespace :store do
    root :to                  => "pages#home", :as => :home
  end

  # Employee Namespace
  #-----------------------------------------------------------------
  devise_for :employees, :path => 'employee', :controllers => {
    :confirmations => 'employee/confirmations',
    :passwords => 'employee/passwords',
    :registrations => 'employee/registrations',
    :sessions => 'employee/sessions',
    :unlocks => 'employee/unlocks'
  }

  namespace :employee do
    root :to                  => "pages#home", :as => :home
  end

  # SSO Clients
  #------------------------------------------------------------------
  resources :clients

  # API
  #------------------------------------------------------------------
  mount OneRing::APIv1 => "/"
end