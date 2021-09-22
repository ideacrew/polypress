# frozen_string_literal: true

Rails
  .application
  .routes
  .draw do
    # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
    mount Ckeditor::Engine => '/ckeditor'
    root 'new/templates#index'

    get 'session/new'
    post 'session/create'
    delete 'session/destroy'
    get 'session/forgot_password'
    put 'session/reset_password'

    resources :accounts, only: %i[new create add_role]

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
