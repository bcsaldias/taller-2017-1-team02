class Invoice < ApplicationRecord
  enum status: [:pendiente, :pagada, :anulada, :rechazada, :aceptada, :despachada]
  belongs_to :purchase_order
  belongs_to :trx, :class_name => 'Transaction', :foreign_key => 'transaction_id'

  def evaluar_si_aceptar
    if self.purchase_order_id.nil?
      self.cause = "Factura no tiene Orden de compra asociada"
      rerturn false
    end

    oc = self.purchase_order
    puts "Cant oc: #{oc.quantity}"
    puts "Precio oc: #{oc.unit_price}"
    total_price_oc = oc.unit_price * oc.quantity
    puts "Total_OC #{total_price_oc}"

    puts "DAtos factura:"
    puts "bruto: #{self.bruto}"
    puts "Total: #{self.bruto + self.iva}"

    if self.bruto + self.iva >= total_price_oc
      return true
    else
      self.cause = "Precio bajo. Price_OC: #{total_price_oc}, Price_factura =#{self.bruto + self.iva}"
      rerturn false
    end
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
