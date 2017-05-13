class PurchaseOrder < ApplicationRecord
  enum state: [:creada, :aceptada, :rechazada, :finalizada]

  belongs_to :product, foreign_key: :product_sku
  has_one :invoice
end
