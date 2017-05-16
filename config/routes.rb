Rails.application.routes.draw do

  root 'dashboard#index'

  #get 'user_sessions/new'
  #get 'user_sessions/create'
  #get 'user_sessions/destroy'
  #root :to => 'users#index'
  resources :user_sessions
  #resources :users
  #resources :factory_manual_managment
  
  get 'login' => 'user_sessions#new', :as => :login
  get 'logout' => 'user_sessions#destroy', :as => :logout
  
  get 'dashboard/index'

  #resources :warehouses
  #resources :invoices
  #resources :purchase_orders
  #resources :contacts
  #resources :recipes
  #resources :products
  #resources :suppliers
  apipie
  get 'test' => 'api#test'

  get 'products' => 'products#available', :as => :managment

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

  root 'dashboard#index', :as => :dashboard

end
