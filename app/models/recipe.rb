class Recipe < ApplicationRecord
  belongs_to :final_product, :class_name => 'Product', foreign_key: :final_product_id
  belongs_to :needed_product, :class_name => 'Product', foreign_key: :needed_product_id
end
