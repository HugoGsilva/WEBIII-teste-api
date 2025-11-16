class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.references :pedido, null: false, foreign_key: true, index: true
      t.references :produto, null: false, foreign_key: true, index: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
