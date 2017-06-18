class Transaction < ActiveRecord::Base
  has_one :invoice

  def self.refresh
    puts "Refrescando transacciones"
    fechaInicio = 1 # Desde 1970
    transactions_query = Bank.get_our_card(9999999999, fechaInicio)
    puts transactions_query
    transactions =  transactions_query['data']
    counter = 0
    cant = 0
    transactions.each do |trx|
      temp_trx = Transaction.where(id_cloud: trx['_id']).first
      cant += 1

      puts "#{trx['_id']}: #{temp_trx}"
      if temp_trx == nil
        owner = (trx['origen'] == Rails.configuration.environment_ids['bank_id'])
        counter += 1
        Transaction.create!(id_cloud: trx['_id'],
                            origen: trx['origen'],
                            destino: trx['destino'],
                            monto: trx['monto'],
                            owner: owner,
                            #state: true
                            )
      else

    	temp_trx.monto = trx['monto']
    	temp_trx.save!
      end
    end
    {ret: "Actualizado!", cant: cant, trx_descargadas: counter}
  end





  def group_number(id_cloud)

    supp = Supplier.get_by_id_cloud(id_cloud)
    
    if supp
      puts supp.id
      group_number = supp.id
      return group_number
    end
    return id_cloud
  end


end
