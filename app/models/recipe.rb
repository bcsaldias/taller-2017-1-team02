class Recipe < ApplicationRecord
  belongs_to :final_product, :class_name => 'Product'
  belongs_to :needed_product, :class_name => 'Product'
end
