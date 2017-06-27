# cronotab.rb — Crono configuration file
#
# Here you can specify periodic jobs and schedule.
# You can use ActiveJob's jobs from `app/jobs/`
# You can use any class. The only requirement is that
# class should have a method `perform` without arguments.
#
class GetSFTP
  def perform
    ret =  FtpOrders.check_orders

    total_ftp = PurchaseOrder.where("group_number == -1")
    created_ftp  = total_ftp.where(state: 0)

    created_ftp.each do |ftp_oc|
    	if ftp_oc.evaluar_si_aceptar
    		Sales.accept_ftp_order(ftp_oc.id_cloud)
    	end
    end

    return Warehouses.activate_queue

    puts 'Shakira!'
  end
end

class ActivePromotions
    def perform
      Promotions.get_ofertas
    end
end

class RestoreStock
    def perform
      puts "Ejecutando crono de restore stock"
      Warehouses.check_and_restore_stock
      puts "Crono finalizada"
    end
end

class SortWarehouses
    def perform
      puts "Ejecutando crono de sort Warehouses"
      Warehouses.sort_warehouses
      puts "Crono finalizada"
    end
end

Crono.perform(GetSFTP).every 18.minutes
#Crono.perform(ActivePromotions).every 8.minutes
Crono.perform(RestoreStock).every 60.minutes
Crono.perform(SortWarehouses).every 45.minutes
