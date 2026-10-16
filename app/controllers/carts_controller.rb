
class CartsController < ApplicationController
  def show
    @cart = current_user.cart
    user_cart_calculation
  end

  def index
    session[:cart] ||= []

    product_ids = session[:cart].map { |item| item["id"] }
    @products = Product.where(id: product_ids).index_by(&:id)
  end

  def add_product
    product = Product.find(cart_params[:product_id])
    count = cart_params[:count].to_i

    if product.sold_out?
      redirect_to product_path(product), alert: "この商品は売り切れです。"
      return
    end

    if count <= 0
      redirect_to product_path(product), alert: "数量を正しく入力してください。"
      return
    end

    session[:cart] ||= []

    item = session[:cart].find do |cart_item|
      cart_item["id"].to_i == product.id
    end

    if item
      item["count"] = item["count"].to_i + count
    else
      session[:cart] << {
        "id" => product.id,
        "count" => count
      }
    end

    cart_calculation

    redirect_to carts_path, notice: "商品がカートに追加されました。"
  end

  def update_quantity
    session[:cart] ||= []

    product_id = params[:id].to_i
    count = params[:count].to_i

    item = session[:cart].find do |cart_item|
      cart_item["id"].to_i == product_id
    end

    if item
      if count > 0
        product = Product.find_by(id: product_id)

        if product.nil? || product.sold_out?
          redirect_to carts_path, alert: "この商品は購入できません。"
          return
        end

        item["count"] = count
      else
        session[:cart].delete(item)
      end
    end

    cart_calculation

    redirect_to carts_path, notice: "カートを更新しました。"
  end

  def remove_item
    session[:cart] ||= []

    product_id = params[:id].to_i

    session[:cart].delete_if do |item|
      item["id"].to_i == product_id
    end

    cart_calculation

    redirect_to carts_path, notice: "商品がカートから削除されました。"
  end

  private

  def cart_params
    params.permit(:product_id, :count)
  end
end
