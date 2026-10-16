
class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    product = Product.find(cart_item_params[:product_id])
    quantity = cart_item_params[:quantity].to_i

    if product.sold_out?
      redirect_to product_path(product), alert: "この商品は売り切れです。"
      return
    end

    if quantity <= 0
      redirect_to product_path(product), alert: "数量を正しく入力してください。"
      return
    end

    cart = current_user.cart || current_user.create_cart

    cart_item = cart.cart_items.find_or_initialize_by(product: product)
    cart_item.quantity = cart_item.quantity.to_i + quantity

    if cart_item.save
      redirect_to cart_path(cart), notice: "商品がカートに追加されました。"
    else
      redirect_to product_path(product), alert: "商品をカートに追加できませんでした。"
    end
  end

  def update
    cart = current_user.cart
    cart_item = cart.cart_items.find(params[:id])

    quantity = cart_item_params[:quantity].to_i

    if cart_item.product.sold_out?
      redirect_to cart_path(cart), alert: "この商品は売り切れです。"
      return
    end

    if quantity <= 0
      redirect_to cart_path(cart), alert: "数量を正しく入力してください。"
      return
    end

    if cart_item.update(quantity: quantity)
      redirect_to cart_path(cart), notice: "商品数量が更新されました。"
    else
      redirect_to cart_path(cart), alert: "商品数量の更新に失敗しました。"
    end
  end

  def destroy
    cart = current_user.cart
    cart_item = cart.cart_items.find(params[:id])

    cart_item.destroy

    redirect_to cart_path(cart), notice: "商品がカートから削除されました。"
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(:product_id, :quantity)
  end
end
