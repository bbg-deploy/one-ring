CustomSsoProvider::Application.routes.draw do
#  use_doorkeeper
  root :to              => "pages#home",             :as => :home

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

  resources :clients

end