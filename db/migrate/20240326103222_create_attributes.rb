class CreateAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :attribute_names do |t|
      t.string :attr_name
      t.references :category

      t.timestamps
    end

    create_table :product_attributes do |t|
      t.string :attr_value
      t.references :attribute_name
      t.references :product_item

      t.timestamps
    end
  end
end
