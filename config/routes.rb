Rails.application.routes.draw do
  devise_for :accounts
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount Ckeditor::Engine => '/ckeditor'
  root 'notice_kinds#index'

  resources :notice_kinds do
    member do
      get :preview
      delete :delete_notice
    end

    collection do
      get :download_notices
      get :get_tokens
      get :get_placeholders
      get :get_recipients
      # post :delete_notices
      post :upload_notices
    end
  end
end
