class AddEmployeeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :employee, null: true, foreign_key: true
  end
end