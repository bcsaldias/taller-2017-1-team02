class Invoice < ApplicationRecord
  enum status: [:pendiente, :pagada, :anulada, :rechazada, :aceptada, :despachada]
  belongs_to :purchase_order
end
