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
#
# Crono.perform(TestJob).every 2.days, at: '15:30'
#

Crono.perform(GetSFTP).every 20.minutes