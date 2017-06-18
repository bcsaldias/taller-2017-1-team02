class Transaction < ActiveRecord::Base
  has_one :invoice
end
