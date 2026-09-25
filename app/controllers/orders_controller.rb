class OrdersController < ApplicationController

  def new
    @order = Order.new
    @cart_items = current_user.cart.cart_items.includes(:product)
    user_cart_calculation
  end

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def confirm
    @order = Order.new(order_params)
    @order.user_id = current_user.id

    @cart_item = current_user.cart.cart_items.includes(:product)

    @cart_item.each do |item|
      @order.order_details.build(
        product_id: item.product.id,
        quantity: item.quantity,
        price: item.product.price
      )
    end

    item_totals = @order.order_details.map do |detail|
      calculate_item_total(detail.price, detail.quantity)
    end

    @order.total_price = calculate_total_sum(item_totals)

    if !@order.valid?
      redirect_to new_order_path, alert: "注文内容に誤りがあります。"
    end
  end

def create
  @order = Order.new(order_params)
  @order.user_id = current_user.id

  if @order.save
    current_user.cart.cart_items.each do |item|
      OrderDetail.create(
        order_id: @order.id,
        product_id: item.product.id,
        quantity: item.quantity,
        price: item.product.price
      )
    end

    current_user.cart.cart_items.destroy_all

    redirect_to complete_order_path(@order)
  else
    redirect_to new_order_path, alert: "注文内容に誤りがあります。"
  end
end

def complete
  @order = Order.find(params[:id])
end
  private

 def order_params
  params.require(:order).permit(
    :address,
    :total_price
  )
end

end