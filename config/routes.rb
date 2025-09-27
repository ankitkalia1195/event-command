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

  # Face authentication routes
  get "face_login", to: "sessions#face_login", as: :face_login
  post "face_authenticate", to: "sessions#face_authenticate", as: :face_authenticate

  # Attendee routes
  get "agenda", to: "agenda#index", as: :agenda
  post "check_in", to: "agenda#check_in", as: :check_in
  get "agenda/session_status", to: "agenda#session_status", as: :agenda_session_status
  get "agenda/check_in_stats", to: "agenda#check_in_stats", as: :agenda_check_in_stats
  get "sessions/:id", to: "sessions#show", as: :session
  get "feedback/session/:id", to: "feedback#new_session", as: :new_session_feedback
  post "feedback/session/:id", to: "feedback#create_session", as: :create_session_feedback
  get "feedback/session/:session_id/edit/:id", to: "feedback#edit_session", as: :edit_session_feedback
  patch "feedback/session/:session_id/:id", to: "feedback#update_session", as: :update_session_feedback
  get "feedback/event", to: "feedback#new_event", as: :new_event_feedback
  post "feedback/event", to: "feedback#create_event", as: :create_event_feedback
  get "feedback/event/edit/:id", to: "feedback#edit_event", as: :edit_event_feedback
  patch "feedback/event/:id", to: "feedback#update_event", as: :update_event_feedback

  # Admin routes
  namespace :admin do
    get "dashboard", to: "admin#dashboard", as: :dashboard
    get "attendees", to: "admin#attendees", as: :attendees
    get "feedback_results", to: "admin#feedback_results", as: :feedback_results
    get "switch_to_attendee", to: "admin#switch_to_attendee_view", as: :switch_to_attendee_view
  end

  # Admin view switcher
  post "switch_to_admin", to: "application#switch_to_admin_view", as: :switch_to_admin
  post "switch_to_attendee", to: "application#switch_to_attendee_view", as: :switch_to_attendee
end
