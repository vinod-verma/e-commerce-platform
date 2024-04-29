class CreateOffer < ActiveRecord::Migration[7.0]
  def change
    create_table :offers do |t|
      t.string :name
      t.string :description
      t.string :discount
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end

    create_table :category_offers do |t|
      t.references :category
      t.references :offer

      t.timestamps
    end
  end
end
