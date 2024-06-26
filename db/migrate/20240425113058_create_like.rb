class CreateLike < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.boolean :is_liked
      t.references :user
      t.references :likeable, polymorphic: true

      t.timestamps
    end
  end
end
