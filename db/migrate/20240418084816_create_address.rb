class CreateAddress < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.references :user
      t.string :name
      t.string :phone
      t.integer :pincode
      t.string :locality
      t.string :address
      t.string :city
      t.string :state
      t.string :landmark
      t.string :alt_phone
      t.string :address_type

      t.timestamps
    end
  end
end
