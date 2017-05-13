class PurchaseOrder < ApplicationRecord
  enum state: [:creada, :aceptada, :rechazada, :finalizada, :anulada]

  belongs_to :product, foreign_key: :product_sku
  has_one :invoice
end
