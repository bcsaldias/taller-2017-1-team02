module Bank
	include Queries
	require 'json'

  def self.transfer(monto, origen, destino)
    # se puede testear usando nuestros ids
    body = {'monto' => monto, 'origen' => origen, 'destino' => destino}
    @result = Queries.put("banco/trx", authorization=false, body)

		transfered = JSON.parse @result.body
		# puts "la transferencia que acabo de hacer"
		# puts transfered

		@transaction = Transaction.create!(id_cloud: transfered['_id'], origen: transfered['origen'],
																	destino: transfered['destino'], monto: transfered['monto'], owner: true, state: true)

		# variable_prueba = Transaction.where(id_cloud: transfered['_id']).first['monto']
		# puts "esta es el elemento de la tabla que tiene el id de la nueva transferencia"
		# puts variable_prueba
		# puts Transaction.where(id_cloud: transfered['_id']).first['id_cloud']
		return JSON.parse @result.body


  end

  def self.get_transaction(transaction_id)
    #ej: dev 592507784df28100043e6cb6
    @result = Queries.get("banco/trx/" + transaction_id)
		return @result
  end

  def self.get_card(fechaInicio, fechaFin, id_cuenta, limit=10)
    # t0 = Tiempo.tiempo_a_milisegundos(05, 15, 23, 00)
    body = {'fechaInicio' => fechaInicio, 'fechaFin' => fechaFin,
            'id' => id_cuenta, 'limit'=> limit}
    @result = Queries.post("banco/cartola", body = body)
    return JSON.parse @result.body
  end

  def self.get_account(account_id)
    @result = Queries.get("banco/cuenta/" + account_id)
    return JSON.parse @result.body
  end

end
