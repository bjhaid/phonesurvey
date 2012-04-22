class AddTrunkLineToProducts < ActiveRecord::Migration
  def change
    add_column :products, :tropo_number, :string
  end
end
