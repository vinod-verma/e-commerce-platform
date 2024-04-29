class CreateCart < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.references :user

      t.timestamps
    end

    create_table :cart_items do |t|
      t.references :cart
      t.references :product_item
      t.integer :qty

      t.timestamps
    end

    create_table :wish_lists do |t|
      t.references :user

      t.timestamps
    end

    create_table :wish_list_items do |t|
      t.references :wish_list
      t.references :product_item

      t.timestamps
    end
  end
end
