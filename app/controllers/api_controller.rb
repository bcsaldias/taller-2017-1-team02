require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

  def generate_authorization(key = 'GbmrOdS%NyVDgbN',
                              method = 'GET',
                              params = [''],
                              base = 'INTEGRACION grupo2:')

    data = method + params.join('')
    _hash = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'),
                                                 key, data)).strip()
    return json_response({"hash": base+_hash})
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
