Spree::Core::Engine.add_routes do

  namespace :admin do
    resources :promese_settings
  end

  namespace :api do
    namespace :v1 do
      resources :promese_webservice, only: [] do
        collection do
          post :retour_b2c
          post :ship_b2c
          post :ship_b2b
          post :stock_update
          post :processed_orders
        end
      end
    end
  end

end
