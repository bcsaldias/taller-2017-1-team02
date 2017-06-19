class PurchaseOrder < ApplicationRecord
  enum state: [:creada, :aceptada, :rechazada, :finalizada, :anulada]

  belongs_to :product, foreign_key: :product_sku
  has_one :invoice
  belongs_to :supplier, foreign_key: :supplier_id
  default_scope { order(deadline: :asc) }


  def self.our_oc
    PurchaseOrder.where(owner: true).each do |item|
        item.cantidad
    end
  end

  def self.requested
		PurchaseOrder.where(owner: nil).each do |item|
        item.cantidad
    end
  end

  def self.can_accept_ftp
    selected_ids = []
    PurchaseOrder.where("group_number == -1").where(state: 0).each do |item|
        if item.evaluar_si_aceptar
          selected_ids << item.id
        end
    end
    return PurchaseOrder.where('id IN (?)', selected_ids)
  end

  def self.cannot_accept_ftp
    selected_ids = []
    PurchaseOrder.where("group_number == -1").where(state: 0).each do |item|
        if not item.evaluar_si_aceptar
          selected_ids << item.id
        end
    end
    return PurchaseOrder.where('id IN (?)', selected_ids)
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

    if !@product or !@product.price
      self.cause = "No vendemos ese producto"
      return false
    end

    puts "Precio producto: #{@product.price}"
    puts "Precio OC: #{self.unit_price}"
    if self.group_number != -1 and self.unit_price < @product.price
      self.cause = "Precio bajo"
      return false
    end

    deadline_in = self.deadline - Time.current
    puts "El deadline es en #{deadline_in} segundos"
    if deadline_in < 4*60*60 # 4 horas
      self.cause = "Muy poco tiempo para procesar - necesitamos 4 horas."
      return false
    end

    #puts "stock_actual: #{stock_actual}"
    #puts "stock_reservado: #{stock_reservado}"

    base = 400 # reservado para nosotros
    if self.group_number == -1
      base = 0
    end

    s_disponible = @product.stock_disponible - base

    if s_disponible < self.quantity
      puts "No_stock"
      self.cause = "no tenemos stock para cumplir plazo."
      return false
    end

    return true
  end

  def invoice(id_cloud_oc)
    inv = Invoice.where(oc_id_cloud: id_cloud_oc).first
    if inv
      return inv.id_cloud
    end
  end


end
