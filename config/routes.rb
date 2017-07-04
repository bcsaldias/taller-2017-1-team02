Rails.application.routes.draw do

  #resources :vouchers
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/ecommerce'
  mount Crono::Web, at: '/crono'

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
  post 'enviar_factura' => 'managments#enviar_factura', as: :enviar_factura
  post 'activate_queue' => 'general#activate_queue', as: :activate_queue
  post 'notify_deliver' => 'managments#notify_deliver', as: :notify_deliver
  post 'pay_invoice' => 'managments#pay_invoice', as: :pay_invoice
  post 'deliver' => 'managments#deliver', as: :deliver
  post 'deliver_ftp' => 'managments#deliver_ftp', as: :deliver_ftp
  post 'create_oc' => 'managments#create_oc', as: :create_oc
  post 'accept_oc' => 'general#accept_oc', as: :accept_oc
  post 'accept_invoice' => 'general#accept_invoice', as: :accept_invoice
  post 'encolar_order' => 'managments#encolar_order', as: :encolar_order
  post 'desencolar_order' => 'managments#desencolar_order', as: :desencolar_order
  post 'accept_ftp' => 'general#accept_ftp', as: :accept_ftp
  post 'detener_despacho' => 'managments#detener_despacho', as: :detener_despacho
  post 'despachar_boleta' => 'managments#despachar_boleta', as: :despachar_boleta
  post 'sent_production' => 'managments#sent_production', as: :sent_production
  post 'mover_cantidad' => 'managments#mover_cantidad', as: :mover_cantidad
  post 'check_for_availablility' => 'managments#check_for_availablility', as: :check_for_availablility
  post 'asociar_factura_transaccion' => 'general#asociar_factura_transaccion', as: :asociar_factura_transaccion


  post 'refresh_transactions' => 'managments#refresh_transactions', as: :refresh_transactions
  post 'refresh_ftp' => 'managments#refresh_ftp', as: :refresh_ftp
  get 'refresh_ftp' => 'managments#refresh_ftp'

  post 'refresh_balance' => 'managments#refresh_balance', as: :refresh_balance

  post 'refresh_purchase_orders' => 'managments#refresh_purchase_orders', as: :refresh_purchase_orders
  post 'refresh_invoices' => 'managments#refresh_invoices', as: :refresh_invoices
  post 'stocks_force_update' => 'managments#stocks_force_update', as: :stocks_force_update

  post 'move_despacho_general' => 'managments#move_despacho_general', as: :move_despacho_general
  post 'move_recepcion_general' => 'managments#move_recepcion_general', as: :move_recepcion_general
  post 'stop_warehouses_reorder' => 'managments#stop_warehouses_reorder', as: :stop_warehouses_reorder


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
  get 'ftp' => 'api#ftp'
  get 'ofertas' => 'api#get_ofertas'
  get 'update_prices' => 'api#update_prices'
  #get 'test' => 'api#test'
  #get 'test2' => 'api#test2'
  #get 'testj3' => 'api#testj3'
  get 'testj4' => 'api#testj4'
  #get 'tiempo' => 'api#tiempo'


  get 'products' => 'products#available'
  get 'api/publico/precios' => 'products#public_prices'

  get 'general' => 'general#index', :as => :general
  get 'oc' => 'general#oc', :as => :oc
  get 'ventas' => 'general#ventas', :as => :ventas
  get 'ftp_oc' => 'general#ftp_oc', :as => :ftp_oc
  get 'transaction' => 'general#transaction', :as => :transaction
  get 'invoices' => 'general#invoices', :as => :invoices
  get 'production' => 'general#production', :as => :production
  get 'vouchers' => 'general#vouchers', :as => :vouchers
  get 'despacho' => 'general#despacho', :as => :despacho
  get 'promociones' => 'general#promociones', :as => :promociones
  get 'queue' => 'general#queue', :as => :queue
  get 'sprint_5' => 'general#sprint_5', :as => :sprint_5

  get 'invoice_and_transactions' => 'general#invoice_and_transactions', :as => :invoice_and_transactions


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
