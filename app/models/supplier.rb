class Supplier < ApplicationRecord
  #has_many :products
  has_many :contacts
  has_many :products, { through: :contacts }
  has_many :purchase_orders

  self.primary_key = :id

  def get_url
    env = Rails.configuration.environment_ids['environment']
    if env == "production"
      self.api_prod
    else
      self.api_dev
    end
  end

end
