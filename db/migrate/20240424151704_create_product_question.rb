class CreateProductQuestion < ActiveRecord::Migration[7.0]
  def change
    create_table :product_questions do |t|
      t.string :question
      t.references :product
      t.references :user

      t.timestamps
    end

    create_table :product_answers do |t|
      t.string :answer
      t.references :product_question
      t.references :user

      t.timestamps
    end
  end
end
