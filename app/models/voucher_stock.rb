class VoucherStock < ApplicationRecord
  belongs_to :voucher, foreign_key: :product_sku

end
