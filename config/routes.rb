CustomSsoProvider::Application.routes.draw do
  root :to => 'home#index'

  devise_for :customers

  devise_for :stores
end
