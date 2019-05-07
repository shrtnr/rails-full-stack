Rails.application.routes.draw do
  scope :api do
    resources :shortcodes do
      resources :visits
    end

    resources :users do
      collection do
        post "auth"
      end
    end
  end

  get "/:key" => "shortcodes#resolve", as: :resolver
end
