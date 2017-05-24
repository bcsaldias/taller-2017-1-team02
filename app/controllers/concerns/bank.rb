module Bank
	include Queries
	require 'json'

  def self.transfer(monto, origen, destino)
    # se puede testear usando nuestros ids
    body = {'monto' => monto, 'origen' => origen, 'destino' => destino}
    @result = Queries.put("banco/trx", authorization=false, body)
    return JSON.parse @result.body
  end

  def self.get_transaction(transaction_id)
    #ej: dev 592507784df28100043e6cb6
    @result = Queries.get("banco/trx/" + transaction_id)
    return JSON.parse @result.body
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
