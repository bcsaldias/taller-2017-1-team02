Rails.application.routes.draw do

  #resources :warehouses
  #resources :invoices
  #resources :purchase_orders
  #resources :contacts
  #resources :recipes
  #resources :products
  #resources :suppliers

  get 'test' => 'api#test'

  get 'products' => 'products#available'

  put 'purchase_orders/:id' => 'purchase_order#realizar_pedido'
  patch 'purchase_orders/:id/accepted' => 'purchase_order#confirmar_orden_compra'
  patch 'purchase_orders/:id/rejected' => 'purchase_order#rechazar_orden_compra'
  #patch 'purchase_orders/:id' => 'purchase_order#responder_orden_compra'

  put 'invoices/:id' => 'invoice#enviar_factura'
  patch 'invoices/:id/accepted' => 'invoice#enviar_confirmacion_factura'
  patch 'invoices/:id/rejected' => 'invoice#enviar_rechazo_factura'
  patch 'invoices/:id/delivered' => 'invoice#notificar_orden_despachada'
  patch 'invoices/:id/paid' => 'invoice#enviar_confirmacion_pago'


  #patch 'suppliers/:id_supplier' => 'suppliers#informar_cuenta_banco'
  get 'buy' => 'products#buy'

end
