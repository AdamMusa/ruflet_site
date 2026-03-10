Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#home"
  # get "docs", to: "docs#index", as: :docs
  # get "docs/:slug", to: "docs#show", as: :doc
end
