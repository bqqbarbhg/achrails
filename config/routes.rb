
Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  scope '(:locale)', locale: /en|fi|de|et/ do

    root 'home#index'
    get '/oidc_error', to: 'home#oidc_error'
    get '/oidc_error/:failed_action', to: 'home#oidc_error', as: 'oidc_action_error'
    get '/oidc_tokens', to: 'home#oidc_tokens'
    get '/new_session', to: 'home#new_session'
    get '/user', to: 'home#show_user'

    resources :groups do
      member do
        post 'join'
        post 'leave'
        post 'invite'
      end
      collection do
        get 'own'
      end
    end

    resources :users
    resources :invitations
    resources :videos do
      collection do
        post 'upload'
        get 'find'
        get 'search'
        get 'own'
      end
      member do
        resources 'shares', only: [:index, :create, :destroy], param: :group do
          collection do
            put 'set_publicity'
          end
        end
        get 'player'
        get 'revisions'
        post 'revert/:revision', to: 'videos#revert', as: 'revert'
        post 'properties'
      end
    end

  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
