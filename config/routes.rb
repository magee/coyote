Rails.application.routes.draw do
  root to: "high_voltage/pages#show", id: "home"

  resources :statuses

  resources :organizations do
    resources :resources
    resources :representations
    resources :memberships, only: %i[index edit update destroy]
    resources :assignments
    resources :contexts 
    resources :meta, except: %i[destroy]
    resources :invitations, only: %i[new create]
  end

  resources :resource_links

  get '/autocompletetags', to: 'images#autocomplete_tags', as: 'autocomplete_tags'

  devise_for :users, 
    only: %i[passwords registrations sessions unlocks], 
    path: '/', 
    path_names: { 
      registration: 'profile'
    }

  resource :registration, only: %i[new update]
  resources :users, only: %i[show] # for viewing other user profiles

  namespace :api, defaults: { format: 'json' } do
    scope :v1 do
      root to: 'root#show'

      resources :resources, only: %i[index show] do
        resources :representations, only: %i[index show]
      end
    end
  end

  namespace :staff do
    resources :users, except: %i[new create]
    resource :user_password_resets, only: %i[create]
  end

  get '/login',  to: redirect('/users/sign_in')
  get '/logout', to: redirect('/users/sign_out')

  apipie

  if ENV["BOOKMARKLET"] == "true"
    match 'coyote' => 'coyote_consumer#iframe', via: [:get]
    match 'coyote_producer' => 'coyote_producer#index', via: [:get]
  end
end
