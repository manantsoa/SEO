Rails.application.routes.draw do
  resources :report

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

root 'pages#index'
match '/report/:id/:pid', :to => 'report#bypage', :constraints => { :id => /[0-9]+(\%7C[0-9]+)*/ }   , via:[:get]
match '/test'          , :to => 'report#test'                                    , via:[:get]
match '/report/:id/hx' , :to => 'report#hx'   , :constraints => { :pid => /[0-9]+(\%7C[0-9]+)*/ }    , via:[:get]
match '/crawler'       , :to => 'pages#configCrawler'                            , via:[:get]
match '/crawler'       , :to => 'pages#submitCrawl', :as => :sites               , via:[:post]
match '/index'         , :to => 'pages#index'                                    , via:[:get]
match '/crawler/:id'       , :to => 'pages#recrawl'                              , via:[:get]
match '/crawler/mobile/:id'       , :to => 'pages#recrawl2'                              , via:[:get]
match '/report/ranks/:id'       , :to => 'report#ranks'                          , via:[:get]
match '/report/ranks/:id'       , :to => 'report#ranks_add'                      , via:[:post]
match '/report/ranks/:id'       , :to => 'report#ranks_destroy'                  , via:[:delete]
match '/report/ranks/:id/export', :to => 'report#ranks_textfile'                 , via:[:get] 
match '/report/ranks/:id/csv', :to => 'report#ranks_csv'                 , via:[:get] 
match '/report/ranks/:id', :to => 'report#ranks_update'                 , via:[:patch] 
match '/report/ranks/:id/:pid'       , :to => 'report#chart', :constraints => { :pid => /[0-9]+(\%7C[0-9]+)*/ }                         , via:[:get]
match '/report'       , :to => 'report#index', :as => :list                      , via:[:get]
match '/report/print/:id', :to => 'report#download'                                  , via:[:get]
match '/report/print-https/:id', :to => 'report#download_https'                                  , via:[:get]
match '/report/print-image/:id', :to => 'report#download_image'                                  , via:[:get]
match '/report/print-https-image/:id', :to => 'report#download_https_image'                                  , via:[:get]
match '/report/print-mobile/:id', :to => 'report#download_mobile'                                  , via:[:get]
match '/report/print-https-mobile/:id', :to => 'report#download_https_mobile'                                  , via:[:get]
match '/report/test/design', :to => 'report#design', via:[:get]
#match '*path' => redirect('/'), via: :get

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
