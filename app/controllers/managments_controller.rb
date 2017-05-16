#include HTTParty
class ManagmentsController < ApplicationController
  before_filter :authorize

  def index
    @purchase_orders = PurchaseOrder.all#.where(owner: true)
  end

  def authorize
    redirect_to '/login' unless current_user
  end

end
