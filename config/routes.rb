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

# Set the default host for the app
Rails.application.routes.default_url_options[:host] = ENV.fetch('API_HOST', 'localhost.com:3000')
