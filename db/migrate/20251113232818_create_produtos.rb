class CreateProdutos < ActiveRecord::Migration[8.1]
  def change
    create_table :produtos do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock_quantity, null: false, default: 0

      t.timestamps
    end

    add_index :produtos, :name
  end
end
