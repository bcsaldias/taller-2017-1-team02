class Recipe < ApplicationRecord
  belongs_to :final_product, :class_name => 'Product', foreign_key: :final_product_sku
  belongs_to :needed_product, :class_name => 'Product', foreign_key: :needed_product_sku
end
