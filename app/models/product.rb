class Product < ApplicationRecord
  belongs_to :supplier, required: false

  self.primary_key = :sku

  has_many :final_product, :class_name => 'Recipe', :foreign_key => 'final_product_id'
  has_many :needed_product, :class_name => 'Recipe', :foreign_key => 'needed_product_id'

  # has_many :owned_surveys, :class_name => 'Survey', :foreign_key => 'owner_id'
  # has_many :admin_surveys, :class_name => 'Survey', :foreign_key => 'admin_id'

end
