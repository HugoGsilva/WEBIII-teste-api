class CreatePedidos < ActiveRecord::Migration[8.1]
  def change
    create_table :pedidos do |t|
      t.string :customer_name, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
