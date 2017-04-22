Rails.application.routes.draw do

  get 'products' => 'api#products'

  put 'invoices/:id' => 'invoice#enviar_confirmacion_factura'
  delete 'invoices/:id' => 'invoice#enviar_rechazo_factura'
  patch 'invoices/:id' => 'invoice#enviar_confirmacion_pago'
  put 'invoices' => 'invoice#enviar_factura'
  patch 'invoices/:id' => 'invoice#notificar_orden_despachada'

  get 'api/oc/recibir/:id' => 'api#recibir_oc'
  get 'api/factura/recibir/:id' => 'api#recibir_factura'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
