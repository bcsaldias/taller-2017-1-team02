require 'json'
require 'net/http'

class ApiController < ApplicationController

  api! "Retorna una lista de los productos, materias primas y precios disponibles
      para venta por la empresa."
  meta :product => {sku:'J20000022', name: 'producto0', price: 20, stock: 100}
  error 404, "Lista de precios no disponible"
  def products
    #list = [{producto1: 1290}, {producto2: 1580}, {producto3:15000}]
    #string = %q({[{"producto1": 1290}, {"producto2": 1580}, {"producto3":15000}]})
    string = [{sku:'J20000022', name: 'producto0', price: 20, stock: 100}, 
              {sku: 'J10999972', name: 'producto1', price: 30, stock: 200}]
    json_response(string)

  end

  # POST /api/oc/recibir
  #def recibir_oc
  #  json_response("se ha recibido la OC: "+params[:id])
  #end

  # GET /sistema_central
  #def get_oc
  	# ir al servidor
    #json_response("se ha ido a buscar la OC: "+params[:id])
  #end

  # POST /api/factura/recibir
  #def recibir_factura
  #  json_response("se ha recibido la factura: "+params[:id])
  #end

  # GET /sistema_central
  #def get_factura
  #  json_response("se ha ido a buscar la factura: "+params[:id])
  #end

end
