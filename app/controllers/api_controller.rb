require 'json'
require 'net/http'

class ApiController < ApplicationController

  api! "Retorna una lista de precio de los productos y materias primas disponibles
      para venta por la empresa, esta incluye Sku de cada producto y su precio."
  def products
    #list = [{producto1: 1290}, {producto2: 1580}, {producto3:15000}]
    #string = %q({[{"producto1": 1290}, {"producto2": 1580}, {"producto3":15000}]})
    string = [{sku:'J20000022', unit_price: 20}, {sku: 'J10999972', unit_price: 30}]
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
