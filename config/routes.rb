# frozen_string_literal: true

Rails
  .application
  .routes
  .draw do

    devise_scope :account do
      get 'accounts/sign_up' => 'application#resource_not_found'
    end

    devise_for :accounts

    # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
    mount Ckeditor::Engine => '/ckeditor'
    root 'new/templates#index'

    namespace :new do
      resources :templates do
        member do
          get :preview
          # delete :delete_notice
        end

        collection do
          post :instant_preview
          get :download_notices
          get :fetch_tokens
          get :fetch_placeholders
          get :fetch_recipients
          post :upload_notices
        end
      end

      resources :sections do
        member do
          get :preview
          # delete :delete_section
        end

        collection do
          post :instant_preview
          get :download_sections

          # get :fetch_tokens
          # get :fetch_placeholders
          # get :fetch_recipients
          post :upload_sections
        end
      end
    end

    # resources :templates do
    #   member do
    #     get :preview
    #     delete :delete_notice
    #   end

    #   collection do
    #     post :instant_preview
    #     get :download_notices
    #     get :fetch_tokens
    #     get :fetch_placeholders
    #     get :fetch_recipients
    #     # post :delete_notices
    #     post :upload_notices
    #   end
    # end
  end
