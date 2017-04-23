Rails.application.routes.draw do



  get 'products' => 'api#products'

  put 'purchase_orders/:id' => 'purchase_order#realizar_pedido'
  
  patch 'purchase_orders/:id' => 'purchase_order#responder_orden_compra'
  patch 'purchase_orders/:id/accepted' => 'purchase_order#confirmar_orden_compra'
  patch 'purchase_orders/:id/rejected' => 'purchase_order#rechazar_orden_compra'

  put 'invoices/:id' => 'invoice#enviar_confirmacion_factura'
  delete 'invoices/:id' => 'invoice#enviar_rechazo_factura'
  patch 'invoices/:id' => 'invoice#enviar_confirmacion_pago'
  put 'invoices' => 'invoice#enviar_factura'

  patch 'invoices/:id/delivered' => 'invoice#notificar_orden_despachada'

  #patch 'suppliers/:id_supplier' => 'suppliers#informar_cuenta_banco'


end
