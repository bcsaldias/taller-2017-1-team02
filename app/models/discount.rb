class Discount < ApplicationRecord

  validates :codigo, uniqueness: true


  def self.old
    ret_id = []
    all.each do |discount|
        if not discount.disponible
            ret_id << discount.id
        end
    end

    where('id IN (?)', ret_id)
  end

  def self.current
    ret_id = []
    all.each do |discount|
        if discount.disponible
            ret_id << discount.id
        end
    end
    where('id IN (?)', ret_id)
  end


  def disponible

    now = (Time.now.to_f * 1000).to_i
    deadline = (self.fin.to_f * 1000).to_i

    if now <= deadline
      return true
    end
    return false

  end

end
