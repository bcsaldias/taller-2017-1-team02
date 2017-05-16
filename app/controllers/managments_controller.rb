#include HTTParty
class ManagmentsController < ApplicationController
  before_filter :authorize

  def index
    @our_purchase_orders = PurchaseOrder.all.where(owner: true)
    @purchase_orders = PurchaseOrder.all.where(owner: nil)
    @production_orders = ProductionOrder.all
  end

  def authorize
    redirect_to '/login' unless current_user
  end

end
