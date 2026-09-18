class ApplicationController < ActionController::Base
  include PriceCalculations

  # Only allow modern browsers supporting webp images, web push, badges,
  # import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  # 商品詳細ページを見た場合のみ、セッションに商品IDを記録する
  before_action :store_recent_product

  # ユーザがログインしている場合、セッションのカート情報をDBのカートにマージする
  before_action :prepare_cart, if: :user_signed_in?

  def after_sign_in_path_for(resource)
    mypage_path(resource)
  end

  def after_sign_out_path_for(resource)
    session.delete(:cart_merged)
    root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :admin_flg])
  end

  private

  # 最近見た商品をセッションに保存するメソッド
  def store_recent_product
    # 商品詳細ページのときだけ処理
    if params[:controller] == 'products' && params[:action] == 'show'
      product_id = params[:id].to_i

      session[:recent_product_ids] ||= []

      # 重複を防ぐ
      session[:recent_product_ids].delete(product_id)

      # 新しい商品を先頭に追加
      session[:recent_product_ids].unshift(product_id)

      # 最大5件まで
      session[:recent_product_ids] = session[:recent_product_ids].take(5)
    end
  end

  # セッションのカート情報をユーザごとのDBカートにマージするメソッド
  def prepare_cart
    # セッションにカートがマージ済みであるか、または管理者ユーザの場合は何もしない
    return if session[:cart_merged] || current_user.admin_flg?

    # ユーザーのカートを取得、なければ作成
    cart = Cart.find_or_create_by(user_id: current_user.id)

    # セッションのカートが空なら何もしない
    return if !session[:cart]

    session[:cart].each do |item|
      # カート内に同じ商品がある場合は数量を更新、ない場合は新規作成
      cart_item = cart.cart_items.find_or_initialize_by(product_id: item["id"])
      cart_item.quantity += item["count"].to_i
      cart_item.save
    end

    # セッションカートを削除
    session.delete(:cart)

    # セッションにマージ済みフラグを設定
    session[:cart_merged] = true
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end