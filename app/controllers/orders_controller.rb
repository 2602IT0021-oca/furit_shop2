class OrdersController < ApplicationController
 def new
   @order = Order.new
   @product = Product.find(params[:product_id])
 end
 def index
   @orders = current_user.orders.all
 end
 def confirm
   @order = Order.new(order_params)
   @product = Product.find(@order.product_id)
   @order.user = current_user
   @order.total_price = @product.price * @order.count
   if @order.valid?
     render :confirm
   else
     render :new
   end
 end
 def create
   @order = current_user.orders.build(order_params)
   if @order.save
     redirect_to complete_order_path(@order)
   else
     @product = Product.find(@order.product_id)
     render :new
   end
 end
def complete
 @order = current_user.orders.find(params[:id])
 @product = @order.product
end
 private
 def order_params
   params.require(:order).permit(
     :product_id,
     :count,
     :address,
     :total_price
   )
 end
end