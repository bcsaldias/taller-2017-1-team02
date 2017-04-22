class SuppliersController < ApplicationController

  require 'json'

  # PATCH 'suppliers/:id'
  def informar_cuenta_banco

      @body =  JSON.parse request.body.read
      @keys = @body.keys
      if not @keys.include?("id_bank_account")
          json_response({ :error => "Debe proporcionar una cuenta bancaria" }, 400)

      else
	    json_response(
					{
					  id_supplier: params[:id_supplier],
					  id_bank_account: params[:id_bank_account],
					}, 200)
	  end

  end

end
