class CreateOrder < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user
      t.references :address
      t.string :total_amount
      t.string :status

      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order
      t.references :product_item
      t.integer :qty
      t.string :price

      t.timestamps
    end
  end
end
