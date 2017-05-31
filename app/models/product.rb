class Product < ApplicationRecord
  # belongs_to :contact, required: false
  has_many :contacts
  has_many :suppliers, { through: :contacts }

  self.primary_key = :sku

  has_many :final_product, :class_name => 'Recipe', :foreign_key => 'final_product_sku'
  has_many :needed_product, :class_name => 'Recipe', :foreign_key => 'needed_product_sku'

  def self.catalogue
    Product.where(owner: true).map { |p| {:sku => p.sku,
                          :name => p.description,
                          :price => p.price,
                          :stock => p.stock_disponible} }
  end

  def self.public_catalogue
    Product.where(owner: true).map { |p| {:sku => p.sku,
                          :price => p.price,
                          :stock => p.stock_disponible} }
  end

  def self.leche
    product = Product.find("7")
    product.stock = Warehouses.product_stock("7")
    product.save!
    product
  end

  def self.our_products
    Product.where(owner: true).each do |item|
        item.stock_disponible
    end
  end

  def self.force_update
    Product.where(owner: true).each do |item|
      item.stock = Warehouses.product_stock(item.sku)
      item.updated_at = DateTime.now
      item.save!
      item.stock_disponible
    end
  end

  def all_stock
    puts "getting stock"

    _now = (DateTime.now.to_f * 1000).to_i
    _then = (self.updated_at.to_f * 1000).to_i

    if _now - _then > 1000*60*60*2 #2 horas
      self.stock = Warehouses.product_stock(self.sku)
      self.updated_at = DateTime.now
      self.save!
    elsif self.stock == nil
      self.stock = Warehouses.product_stock(self.sku)
      self.updated_at = DateTime.now
      self.save!
    end
    
    self.stock

  end

  # Retorna el stock del producto que esta comprometido para la venta con OC's o ecommerce
  def reserved_stock
    stock_reservado = 0
    PurchaseOrder.where(owner: nil, product_sku: self.sku, state: 1).each do |po|
      stock_reservado += po.quantity
    end

    lines = Spree::LineItem.all
    lines.each do |line|
      line_sku = Spree::Variant.find(line.variant_id).sku.to_s
      if self.sku.to_s == line_sku
        stock_reservado += line.quantity.to_i
      end
    end

    stock_reservado
  end

  def stock_disponible
    stock_actual = self.all_stock
    stock_reservado = self.reserved_stock
    return stock_actual - stock_reservado
  end


end
