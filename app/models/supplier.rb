class Supplier < ApplicationRecord
  #has_many :products
  has_many :contacts
  has_many :products, { through: :contacts }

  self.primary_key = :id

end
