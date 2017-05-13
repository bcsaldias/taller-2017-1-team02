class Contact < ApplicationRecord
  # has_many :products

  belongs_to :product
  belongs_to :supplier

end
