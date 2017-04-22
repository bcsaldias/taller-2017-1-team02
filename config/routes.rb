Rails.application.routes.draw do


  get 'products' => 'api#products'

  put 'purchase_orders/:id' => 'purchase_order#realizar_pedido'
  patch 'purchase_orders/:id' => 'purchase_order#responder_orden_compra'

  put 'invoices/:id' => 'invoice#enviar_confirmacion_factura'
  delete 'invoices/:id' => 'invoice#enviar_rechazo_factura'
  patch 'invoices/:id' => 'invoice#enviar_confirmacion_pago'
  put 'invoices' => 'invoice#enviar_factura'
  patch 'invoices/:id' => 'invoice#notificar_orden_despachada'


end
