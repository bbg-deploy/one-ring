CustomSsoProvider::Application.routes.draw do
  root :to => 'home#index'

  devise_for :customers
end
