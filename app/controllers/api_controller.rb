require 'json'
require 'net/http'

class ApiController < ApplicationController
  def prices
    json_response("DEV: lista de precios")
  end

  # POST /api/oc/recibir
  def recibir_oc
    json_response("se ha recibido la OC: "+params[:id])
  end

  # GET /sistema_central
  def get_oc
  	# ir al servidor
    json_response("se ha ido a buscar la OC: "+params[:id])
  end

  # POST /api/factura/recibir
  def recibir_factura
    json_response("se ha recibido la factura: "+params[:id])
  end

  # GET /sistema_central
  def get_factura
    json_response("se ha ido a buscar la factura: "+params[:id])
  end



end
