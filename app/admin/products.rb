ActiveAdmin.register Product do
  permit_params :name, :description, :category_id, :manufacturer_id, :created_at, :updated_at
  menu parent: "Product Management", label: 'Product'

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :category do |resource|
      category = resource.category
      "#{category.category_name}"
    end
    column :manufacturer do |resource|
      manufacturer = resource.manufacturer
      "#{manufacturer.name}" if manufacturer
    end
    column :created_at
    column :updated_at
    actions
  end

  filter :name

  show do 
    attributes_table do
      row :name
      row :description
      row :category do |resource|
        category = resource.category
        "#{category.category_name}"
      end
      row :manufacturer do |resource|
        manufacturer = resource.manufacturer
        "#{manufacturer.name}" if manufacturer
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :category_id, as: :select, include_blank: false, prompt: "Select category", collection: Category.all.map {|f| [f.category_name, f.id]}
      f.input :manufacturer_id, as: :select, include_blank: false, prompt: "Select manufacturer", collection: Manufacturer.all.map {|f| [f.name, f.id]}
    end
    f.actions
  end

end
