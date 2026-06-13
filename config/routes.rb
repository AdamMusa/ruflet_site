Rails.application.routes.draw do
  mount_avo at: "/admin"

  # Native mobile/desktop clients connect here. The home screen is declared in
  # app/views/ruflet/main.rb (dev code) — explicitly mounted, not auto-mounted.
  match "/ws", to: Ruflet::Rails.app(Rails.root.join("app/views/ruflet/main.rb")), via: :all

  # Web frontend: serves the prebuilt web client from frontend/ (rake ruflet:web)
  # and answers the WebSocket on the same mount point.
  mount Ruflet::Rails.web_app(app_file: Rails.root.join("app/views/ruflet/main.rb")), at: "/showcase"

  resources :newsletter_subscriptions, only: :create
  resource :session
  get "docs", to: "docs#index", as: :docs
  get "docs/:slug", to: "docs#show", as: :doc
  get "privacy", to: "pages#privacy", as: :privacy
  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#home"
end
