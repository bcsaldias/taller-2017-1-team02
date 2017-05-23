module Bank
	include Queries
	require 'json'

  def self.transfer(monto, origen, destino)
    body = {'monto' => monto, 'origen' => origen, 'destino' => destino}
    @result = Queries.put("banco/trx", body = body)
    return JSON.parse @result.body
  end

  def self.get_transaction(transaction_id)
    @result = Queries.get("banco/trx/" + transaction_id)
    return JSON.parse @result.body
  end

  def self.get_card(fechaInicio, fechaFin, id_cuenta, limit)
    body = {'fechaInicio' => fechaInicio, 'fechaFin' => fechaFin, 'id_cuenta' => id_cuenta}
    @result = Queries.post("banco/cartola", body = body)
    return JSON.parse @result.body
  end

  def self.get_account(account_id)
    @result = Queries.get("banco/cuenta/" + account_id)
    return JSON.parse @result.body
  end

end
