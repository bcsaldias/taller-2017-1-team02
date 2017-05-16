class PurchaseOrder < ApplicationRecord
  enum state: [:creada, :aceptada, :rechazada, :finalizada]

  belongs_to :product, foreign_key: :product_sku
  has_one :invoice
  belongs_to :supplier, foreign_key: :supplier_id

end
