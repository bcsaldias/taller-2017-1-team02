module Bank
	include Queries
	require 'json'

  def self.transfer(monto, origen, destino)
    # se puede testear usando nuestros ids
    body = {'monto' => monto, 'origen' => origen, 'destino' => destino}
    @result = Queries.put("banco/trx", authorization=false, body)

		puts "bODY RESPUESTA: #{@result.body}"
		puts "CODE RESPUESTA: #{@result.code}"

    status = (@result.code == 200)
    id = nil

    if status
  		transfered = JSON.parse @result.body
      id = transfered['_id']
  		puts "la transferencia que acabo de hacer EXITOSA!"
  		puts transfered
    end

		@transaction = Transaction.create!(id_cloud: id,
                                  origen: origen,
																	destino: destino,
                                  monto: monto,
                                  owner: true, state: status)

		# variable_prueba = Transaction.where(id_cloud: transfered['_id']).first['monto']
		# puts "esta es el elemento de la tabla que tiene el id de la nueva transferencia"
		# puts variable_prueba
		# puts Transaction.where(id_cloud: transfered['_id']).first['id_cloud']
		return @transaction


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

  def self.get_our_card(limit=10, fechaInicio=nil, fechaFin=nil)
    @fechaInicio = fechaInicio
    @fechaFin = fechaFin

    if @fechaInicio == nil
      @fechaInicio = (Time.now - 4.minutes).to_f*1000 # 5 minutos
    end
    if @fechaFin == nil
      @fechaFin =  Time.now.to_f*1000
    end

    id_cuenta = Rails.configuration.environment_ids['bank_id']
    body = {'fechaInicio' => @fechaInicio, 'fechaFin' => @fechaFin,
            'id' => id_cuenta, 'limit'=> limit}
    @result = Queries.post("banco/cartola", body = body)
    return @result
  end


  def self.get_account(account_id)
    @result = Queries.get("banco/cuenta/" + account_id)
    return JSON.parse @result.body
  end

end
