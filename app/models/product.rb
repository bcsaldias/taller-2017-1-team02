class Product < ApplicationRecord
  belongs_to :contact, required: false

  self.primary_key = :sku

  has_many :final_product, :class_name => 'Recipe', :foreign_key => 'final_product_id'
  has_many :needed_product, :class_name => 'Recipe', :foreign_key => 'needed_product_id'

end
