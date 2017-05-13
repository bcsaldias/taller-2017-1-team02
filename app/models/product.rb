class Product < ApplicationRecord
  # belongs_to :contact, required: false
  has_many :contacts
  has_many :suppliers, { through: :contacts }

  self.primary_key = :sku

  has_many :final_product, :class_name => 'Recipe', :foreign_key => 'final_product_id'
  has_many :needed_product, :class_name => 'Recipe', :foreign_key => 'needed_product_id'

  def self.catalogue
  	Product.all.where(owner: true).map { |p| {:sku => p.sku,
  												:name => p.description,
  												:price => p.price,
  												:stock => p.stock} }
  end


end
