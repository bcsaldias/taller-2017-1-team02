Rails.application.routes.draw do

  get 'api/prices'
  get 'api/oc/recibir/:id' => 'api#recibir_oc'
  get 'api/factura/recibir/:id' => 'api#recibir_factura'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
