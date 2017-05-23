class Product < ApplicationRecord
  # belongs_to :contact, required: false
  has_many :contacts
  has_many :suppliers, { through: :contacts }

  self.primary_key = :sku

  has_many :final_product, :class_name => 'Recipe', :foreign_key => 'final_product_sku'
  has_many :needed_product, :class_name => 'Recipe', :foreign_key => 'needed_product_sku'

  def self.catalogue
  	Product.all.where(owner: true).map { |p| {:sku => p.sku,
  												:name => p.description,
  												:price => p.price,
  												:stock => p.stock} }
  end

  def self.public_catalogue
    Product.all.where(owner: true).map { |p| {:sku => p.sku,
                          :price => p.price,
                          :stock => p.stock} }
  end

  def self.our_products
    Product.all.where(owner: true).each do |item|

      #estamos corridos 4 horas.
      if (DateTime.now.to_f * 1000).to_i - (item.updated_at.to_f * 1000).to_i > 1000*60*60*(4)
        item.all_stock
      else
        item.stock
      end

    end
  end


  def all_stock
    self.stock = Warehouses.product_stock(self.sku)
    self.save
  end

end
