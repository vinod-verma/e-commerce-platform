class CreateReview < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.string :title
      t.text :description
      t.integer :rating
      t.references :reviewable, polymorphic: true
      t.references :user

      t.timestamps
    end

    create_table :images do |t|
      t.integer :rank
      t.references :imageable, polymorphic: true

      t.timestamps
    end
  end
end
