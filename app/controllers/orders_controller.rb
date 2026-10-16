
class OrdersController < ApplicationController
  before_action :authenticate_user!

  def new
    @order = Order.new
    @cart_items = current_user.cart&.cart_items&.includes(:product) || []

    if @cart_items.empty?
      redirect_to products_path, alert: "カートが空です。"
      return
    end
    
    if cart_items.any? { |item| item.product.sold_out? }
      redirect_to cart_path(current_user.cart),
                  alert: "売り切れの商品がカートに含まれています。"
      return
    end

    if cart_items.any? { |item| item.quantity <= 0 }
      redirect_to cart_path(current_user.cart),
                  alert: "商品の数量が正しくありません。"
      return
    end


    @item_totals = @cart_items.map do |item|
      item.product.price * item.quantity
    end
    @cart_total = @item_totals.sum
  end

  def index
    @orders = current_user.orders
                          .includes(order_details: :product)
                          .order(created_at: :desc)
  end

  def confirm
    @order = current_user.orders.build(address: order_params[:address])
    cart_items = current_user.cart&.cart_items&.includes(:product) || []

    if cart_items.empty?
      redirect_to products_path, alert: "カートが空です。"
      return
    end

    cart_items.each do |item|
      @order.order_details.build(
        product: item.product,
        quantity: item.quantity,
        price: item.product.price
      )
    end

    @order.total_price = @order.order_details.sum do |detail|
      detail.price * detail.quantity
    end

    unless @order.valid?
      redirect_to new_order_path, alert: "配送先を確認してください。"
    end
  end

  def create
    cart = current_user.cart
    cart_items = cart&.cart_items&.includes(:product)&.to_a || []

    if cart_items.empty?
      redirect_to products_path, alert: "カートが空です。"
      return
    end
    if cart_items.any? { |item| item.product.sold_out? }
  redirect_to cart_path(cart), alert: "売り切れの商品がカートに含まれています。"
  return
end

if cart_items.any? { |item| item.quantity <= 0 }
  redirect_to cart_path(cart), alert: "商品の数量が正しくありません。"
  return
end

    @order = current_user.orders.build(address: order_params[:address])

    cart_items.each do |item|
      @order.order_details.build(
        product: item.product,
        quantity: item.quantity,
        price: item.product.price
      )
    end

    @order.total_price = @order.order_details.sum do |detail|
      detail.price * detail.quantity
    end

    if @order.save
      cart.cart_items.destroy_all
      redirect_to complete_order_path(@order)
    else
      redirect_to new_order_path, alert: "注文を保存できませんでした。"
    end
  end

  def complete
    @order = current_user.orders
                         .includes(order_details: :product)
                         .find(params[:id])
  end

  private

  def order_params
    params.require(:order).permit(:address)
  end
end
