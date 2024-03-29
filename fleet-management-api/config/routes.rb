# frozen_string_literal: true

Rails.application.routes.draw do
  get '/', to: 'home#index'
  resources :vehicles
  resources :packages
  resources :delivery_points
  resources :bags

  post 'add_package_to_bag' => 'packages#add_package_to_bag'
  post 'load_and_unload_shipments' => 'vehicles#load_and_unload_shipments'
end
