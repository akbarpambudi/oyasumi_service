Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # API routes
  post "auth/sign_in" => "auth#sign_in"
  post "auth/sign_up" => "auth#sign_up"

  get "sleep_records" => "sleep_records#show"
  post "sleep_records" => "sleep_records#clock_in"
  patch "sleep_records/:id" => "sleep_records#clock_out"

  get "users/me" => "users#me"
  post "users/me/follow/:id" => "users#follow_user"
  delete "users/me/follow/:id" => "users#un_follow_user"
  get "users/me/following_sleep_records" => "users#following_sleep_records"
  get "users" => "users#index"
  get "users/:id" => "users#show"

  # Handle 404 errors
  match '/404', to: 'errors#not_found', via: :all

  # Handle 500 errors
  match '/500', to: 'errors#internal_server_error', via: :all

  # Handle root path
  root to: 'hello#index'

  get 'health', to: 'health#index'

  # Catch all other routes and redirect to 404
  match '*path', to: 'errors#not_found', via: :all

end
