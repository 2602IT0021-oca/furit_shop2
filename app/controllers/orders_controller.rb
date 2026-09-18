class OrdersController < ApplicationController

  def new
    @order = Order.new
    @cart_items = current_user.cart.cart_items.includes(:product)
    user_cart_calculation
  end

  def index
    @orders = current_user.orders.all
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