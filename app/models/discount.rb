class Discount < ApplicationRecord

  def disponible

    now = (DateTime.now.to_f * 1000).to_i
    deadline = (self.fin.to_f * 1000).to_i

    if now <= deadline
      return true
    end
    return false

  end

end
