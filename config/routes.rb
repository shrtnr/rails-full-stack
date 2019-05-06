Rails.application.routes.draw do
  scope :api do
    resources :shortcodes
    resources :visits

    resources :users do
      collection do
        post "auth"
      end
    end
  end

  get "/:shortcode" => "shortcodes#resolve", as: :resolver
end
