Rails.application.routes.draw do
  mount_avo at: "/admin"
  resources :newsletter_subscriptions, only: :create
  resource :session
  get "docs", to: "docs#index", as: :docs
  get "docs/:slug", to: "docs#show", as: :doc
  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#home"
end
