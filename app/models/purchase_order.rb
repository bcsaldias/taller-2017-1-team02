class PurchaseOrder < ApplicationRecord
  enum state: [:creada, :aceptada, :rechazada, :finalizada]

  belongs_to :product, foreign_key: :product_sku
  has_one :invoice
  belongs_to :supplier, foreign_key: :supplier_id


  def self.our_oc
    PurchaseOrder.all.where(owner: true).each do |item|
        item.cantidad
    end
  end


  def cantidad
  	order = Sales.get_purchase_order(self.id_cloud)
  	order['cantidad']
  end

  def deadline
  	order = Sales.get_purchase_order(self.id_cloud)
  	order['fechaEntrega']
  end

end
