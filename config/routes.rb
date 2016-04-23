Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :weathers, only: [] do
        collection do
          get :forecast
          get :aviation_weather
        end
      end
    end
  end
end
