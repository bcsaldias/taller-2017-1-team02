class PurchaseOrder < ApplicationRecord
  enum state: [:creada, :aceptada, :rechazada, :finalizada, :anulada]

  belongs_to :product, foreign_key: :product_sku
  has_one :invoice
  belongs_to :supplier, foreign_key: :supplier_id


  def self.our_oc
    PurchaseOrder.all.where(owner: true).each do |item|
        item.cantidad
    end
  end

  def self.requested
		PurchaseOrder.all.where(owner: nil).each do |item|
        item.cantidad
    end
  end


  def cantidad
  	order = Sales.get_purchase_order(self.id_cloud)
  	order['cantidad']
  end

  # def deadline
  #  	order = Sales.get_purchase_order(self.id_cloud)
  #   order['fechaEntrega']
  # end

  # Evalua si la OC es cumplible.
  # Considera stock actual y todas las OC aceptadas en el momento
  # No considera la posibilidad de producir antes del deadline.
  def evaluar_si_aceptar
    sku = self.product_sku
    @product = Product.find_by(sku: sku)


    puts "Precio producto: #{@product.price}"
    puts "Precio OC: #{self.unit_price}"
    if self.unit_price < @product.price
      self.cause = "Precio bajo"
      return false
    end

    deadline_in = self.deadline - Time.current
    puts "El deadline es en #{deadline_in} segundos"
    if deadline_in < 60*60 # 1 horas
      self.cause = "Muy poco tiempo para procesar"
      return false
    end

    @product.all_stock
    stock_actual = @product.stock
    stock_reservado = 0
    # pos = PurchaseOrder.where(owner: false, product_sku: sku, state: 1)
    PurchaseOrder.where(owner: nil, product_sku: sku, state: 1).each do |po|
      stock_reservado += po.quantity
    end
    puts "stock_actual: #{stock_actual}"
    puts "stock_reservado: #{stock_reservado}"
    s_disponible = stock_actual - stock_reservado
    if s_disponible < self.quantity
      puts "No_stock"
      self.cause = "no tenemos stock para cumplir plazo"
      return false
    end

    return true
  end


end
