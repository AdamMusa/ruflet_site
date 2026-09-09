Rails.application.routes.draw do
  mount_avo at: "/admin"

  # Native screens run inside this connection; website routes stay separate.
  match "/ws", to: Ruflet::Rails.native { |page|
    Ruflet::Rails.erb_to_native(page, start_url: "/native", fetcher: NativeScreenSource.new)
    page.update(page.views.first, bgcolor: "#FFFFFF", padding: 0)
  }, via: :all

  resources :newsletter_subscriptions, only: :create
  resource :session
  get "docs", to: "docs#index", as: :docs
  get "docs/:slug", to: "docs#show", as: :doc
  get "privacy", to: "pages#privacy", as: :privacy
  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#home"
end
