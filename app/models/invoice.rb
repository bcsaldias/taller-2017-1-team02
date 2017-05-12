class Invoice < ApplicationRecord
  enum state: [:pendiente, :pagada, :anulada, :rechazada]
  belongs_to :purchase_order
end
