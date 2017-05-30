Rails.application.routes.draw do

  #resources :vouchers
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/ecommerce'

  get 'ecommerce/order/paid/:id' => 'spree/checkout#paid'

  root 'dashboard#index'

  #get 'user_sessions/new'
  #get 'user_sessions/create'
  #get 'user_sessions/destroy'
  #root :to => 'users#index'
  resources :user_sessions
  resources :users
  #resources :factory_manual_managment

  get 'login' => 'user_sessions#new', :as => :login
  get 'logout' => 'user_sessions#destroy', :as => :logout

  post 'sort_wh' => 'managments#sort_wh', as: :sort_warehouses
  post 'notify_deliver' => 'managments#notify_deliver', as: :notify_deliver
  post 'deliver' => 'managments#deliver', as: :deliver
  post 'create_oc' => 'managments#create_oc', as: :create_oc
  post 'accept_oc' => 'managments#accept_oc', as: :accept_oc
  post 'sent_production' => 'managments#sent_production', as: :sent_production
  post 'check_for_availablility' => 'managments#check_for_availablility', as: :check_for_availablility

  post 'refresh_transactions' => 'managments#refresh_transactions', as: :refresh_transactions
  post 'refresh_purchase_orders' => 'managments#refresh_purchase_orders', as: :refresh_purchase_orders

  get 'dashboard/index'

  post 'create_oc_with_price' => 'managments#create_oc_with_price', as: :create_oc_with_price

  #resources :warehouses
  #resources :invoices
  #resources :purchase_orders
  #resources :contacts
  #resources :recipes
  #resources :products
  #resources :suppliers
  apipie
  get 'test' => 'api#test'
  get 'test2' => 'api#test2'
  get 'testj3' => 'api#testj3'
  get 'testj4' => 'api#testj4'
  get 'tiempo' => 'api#tiempo'


  get 'products' => 'products#available'
  get 'api/publico/precios' => 'products#public_prices'

  get 'general' => 'general#index', :as => :general
  get 'factory_managment' => 'managments#index', :as => :managment

  put 'purchase_orders/:id' => 'purchase_orders#realizar_pedido'

  patch 'purchase_orders/:id/accepted' => 'purchase_orders#confirmar_orden_compra'
  patch 'purchase_orders/:id/rejected' => 'purchase_orders#rechazar_orden_compra'
  #patch 'purchase_orders/:id' => 'purchase_order#responder_orden_compra'

  put 'invoices/:id' => 'invoices#enviar_factura'
  patch 'invoices/:id/accepted' => 'invoices#enviar_confirmacion_factura'
  patch 'invoices/:id/rejected' => 'invoices#enviar_rechazo_factura'
  patch 'invoices/:id/delivered' => 'invoices#notificar_orden_despachada'
  patch 'invoices/:id/paid' => 'invoices#enviar_confirmacion_pago'


  #patch 'suppliers/:id_supplier' => 'suppliers#informar_cuenta_banco'
  get 'buy' => 'products#buy'
  get 'validaciones' => 'api#validacion_local_servidor'
  get 'actualizar_deadlines_purchase_orders' => 'api#actualizar_deadlines_purchase_orders'

  root 'dashboard#index', :as => :dashboard

end
