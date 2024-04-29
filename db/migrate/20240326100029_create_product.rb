class CreateProduct < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.references :category

      t.timestamps
    end

    create_table :variation_options do |t|
      t.string :value
      t.references :option

      t.timestamps
    end

    create_table :product_items do |t|
      t.string :sku
      t.string :price
      t.integer :qty_in_stock
      t.references :product
      t.references :variation_option

      t.timestamps
    end
  end
end
