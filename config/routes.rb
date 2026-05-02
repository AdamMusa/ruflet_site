Rails.application.routes.draw do
  mount_avo at: "/admin"
  mount Ruflet::Rails.mobile(Rails.root.join("app/views/mobile/main.rb")), at: "/ws"
  resources :newsletter_subscriptions, only: :create
  resource :session
  get "docs", to: "docs#index", as: :docs
  get "docs/:slug", to: "docs#show", as: :doc
  get "privacy", to: "pages#privacy", as: :privacy
  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#home"
end
