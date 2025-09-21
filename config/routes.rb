Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  root "sessions#new"
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  get "magic_login/:token", to: "magic_login#show", as: :magic_login

  # Attendee routes
  get "agenda", to: "agenda#index", as: :agenda
  post "check_in", to: "agenda#check_in", as: :check_in
  get "sessions/:id", to: "sessions#show", as: :session
  get "feedback/session/:id", to: "feedback#new_session", as: :new_session_feedback
  post "feedback/session/:id", to: "feedback#create_session", as: :create_session_feedback
  get "feedback/event", to: "feedback#new_event", as: :new_event_feedback
  post "feedback/event", to: "feedback#create_event", as: :create_event_feedback

  # Admin routes
  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard
    get "attendees", to: "attendees#index", as: :attendees
    get "attendees/export", to: "attendees#export", as: :export_attendees
    get "feedback", to: "feedback#index", as: :feedback
    get "sessions", to: "sessions#index", as: :sessions
    get "sessions/new", to: "sessions#new", as: :new_session
    post "sessions", to: "sessions#create"
    get "sessions/:id/edit", to: "sessions#edit", as: :edit_session
    patch "sessions/:id", to: "sessions#update"
    delete "sessions/:id", to: "sessions#destroy"
  end

  # Admin view switcher
  post "switch_to_admin", to: "application#switch_to_admin_view", as: :switch_to_admin
  post "switch_to_attendee", to: "application#switch_to_attendee_view", as: :switch_to_attendee
end
