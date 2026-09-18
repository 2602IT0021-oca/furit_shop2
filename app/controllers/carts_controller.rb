class CartsController < ApplicationController
def show
  @cart = Cart.find_by(user_id: current_user.id)
  user_cart_calculation
end

  def index
    # セッションからカートの情報を取得
    if session[:cart].present?
      # カート内の商品IDを取得
      product_ids = session[:cart].map { |item| item["id"] }

      # 商品情報を取得してIDをキーにする
      @products = Product.where(id: product_ids).index_by(&:id)
    end
  end

  def add_product
    session[:cart] ||= []

    product = Product.find(cart_params[:product_id])
    count = cart_params[:count].to_i

    if session[:cart].none? { |item| item["id"] == product.id }
      session[:cart] << { "id" => product.id, "count" => count }
    else
      item = session[:cart].find { |item| item["id"] == product.id }
      item["count"] += count if item
    end

    cart_calculation

    redirect_to carts_path, notice: '商品がカートに追加されました。'
  end

  def update_quantity
    product_id = params[:id].to_i
    reduce_count = params[:count].to_i

    item = session[:cart].find { |item| item["id"] == product_id }

    if item
      item["count"] = reduce_count
      session[:cart].delete(item) if item["count"] <= 0
    end

    cart_calculation

    redirect_to carts_path, notice: '商品がカートから削除されました。'
  end

  def remove_item
    product_id = params[:id].to_i

    session[:cart].delete_if { |item| item["id"] == product_id }

    cart_calculation

    redirect_to carts_path, notice: '商品がカートから削除されました。'
  end

  private

  def cart_params
    params.permit(:product_id, :count)
  end
end