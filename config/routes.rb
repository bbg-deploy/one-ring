Onering::Application.routes.draw do
  root :to              => "pages#home",             :as => :home
  get 'learn_more'      => "pages#learn_more",       :as => :learn_more
  get "about"           => "pages#about",            :as => :about
  get "for_business"    => "pages#for_business",     :as => :store
  get "employees"       => "pages#employees",        :as => :employee
  get "security"        => "pages#security",         :as => :security
  get "privacy"         => "pages#privacy",          :as => :privacy
  get "contact"         => "pages#contact",          :as => :contact


  # OmniAuth Provider paths
  #-----------------------------------------------------------------
  match '/oauth/authorize' => 'auth#authorize', :as => :authorization
  match '/oauth/access_token' => 'auth#access_token'
  match '/oauth/customer' => 'auth#customer'

  # Customer Namespace
  #-----------------------------------------------------------------
  devise_for :customers, :path => 'customer', :controllers => {
    :confirmations => 'customer/confirmations',
    :passwords => 'customer/passwords',
    :registrations => 'customer/registrations',
    :sessions => 'customer/sessions',
    :unlocks => 'customer/unlocks'
  }

  devise_scope :customer do
    get '/customer/scope_conflict' => 'customer/sessions#scope_conflict'
    delete '/customer/resolve_conflict' => 'customer/sessions#resolve_conflict'
  end
    
  namespace :customer do
    root :to                  => "pages#home", :as => :home
    resources :payment_profiles, :path => "payment_methods"
    resources :payments, :only => [:index, :new, :create]
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

  devise_scope :store do
    get '/store/scope_conflict' => 'store/sessions#scope_conflict'
    delete '/store/resolve_conflict' => 'store/sessions#resolve_conflict'
  end

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

  devise_scope :employee do
    get '/employee/scope_conflict' => 'employee/sessions#scope_conflict'
    delete '/employee/resolve_conflict' => 'employee/sessions#resolve_conflict'
  end

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