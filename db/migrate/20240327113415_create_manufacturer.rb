class CreateManufacturer < ActiveRecord::Migration[7.0]
  def change
    create_table :manufacturers do |t|
      t.string :name
      t.string :location
      t.string :contact_info

      t.timestamps
    end
    
    create_table :suppliers do |t|
      t.string :name
      t.string :location
      t.string :contact_info
      
      t.timestamps
    end
    
    create_table :product_suppliers do |t|
      t.references :product_item
      t.references :supplier
      
      t.timestamps
    end

    add_reference :products, :manufacturer, foreign_key: true
    add_reference :product_items, :supplier, foreign_key: true
  end
end
