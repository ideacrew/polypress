# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :accounts
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount Ckeditor::Engine => '/ckeditor'
  root 'templates#index'

  resources :templates do
    member do
      get :preview
      delete :delete_notice
    end

    collection do
      get :download_notices
      get :fetch_tokens
      get :fetch_placeholders
      get :fetch_recipients
      # post :delete_notices
      post :upload_notices
    end
  end
end
