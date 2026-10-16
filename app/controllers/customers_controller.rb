class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

def index
  @q = User.where(admin_flg: false).ransack(params[:q])
  @customers = @q.result(distinct: true)
                 .includes(:employee)
                 .order(:id)
  @employees = Employee.order(:name)
end

  def show
    @customer = User.where(admin_flg: false).find(params[:id])
  end

  def edit
    @customer = User.where(admin_flg: false).find(params[:id])
    @employees = Employee.order(:name)
  end
  def update
  @customer = User.where(admin_flg: false).find(params[:id])

  if @customer.update(customer_params)
    redirect_to customer_path(@customer), notice: "顧客情報を更新しました。"
  else
    @employees = Employee.order(:name)
    render :edit, status: :unprocessable_entity
  end
end

  private

  def require_admin
    unless current_user.admin_flg?
      redirect_to products_path, alert: "管理者のみアクセスできます。"
    end
  end
  def customer_params
  params.require(:user).permit(:age, :employee_id)
end
end