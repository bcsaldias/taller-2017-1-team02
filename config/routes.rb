Rails.application.routes.draw do

  get 'invoice/enviar_confirmacion_factura'
  get 'invoice/enviar_rechazo_factura'
  get 'invoice/enviar_confirmacion_pago'
  get 'invoice/enviar_factura'
  get 'invoice/notificar_orden_despachada'

  get 'products' => 'api#products'
  
  get 'api/oc/recibir/:id' => 'api#recibir_oc'
  get 'api/factura/recibir/:id' => 'api#recibir_factura'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
