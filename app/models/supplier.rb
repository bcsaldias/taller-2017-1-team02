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

  def api
    self.get_url()
  end

  def id_cloud
    env = Rails.configuration.environment_ids['environment']
    if env == "production"
      self.id_cloud_prod
    else
      self.id_cloud_dev
    end
  end

  def self.get_by_id_cloud(id_cloud)
    env = Rails.configuration.environment_ids['environment']
    if env == "production"
      where({ id_cloud_prod: id_cloud }).first
    else
      where({ id_cloud_dev: id_cloud }).first
      # where({ id_cloud_dev: id_cloud })
    end
  end




end
