ActiveAdmin.register CategoryAttribute do
  permit_params :attr_name, :category_id, :created_at, :updated_at
  menu parent: "Product Management", label: 'Manage Product Attributes'

  index do
    selectable_column
    id_column
    column :attr_name
    column :category do |resource|
      product = resource.category
      "#{product.category_name}"
    end
    column :created_at
    column :updated_at
    actions
  end

  filter :attr_name

  show do 
    attributes_table do
      row :attr_name
      row :category do |resource|
        product = resource.category
        "#{product.category_name}"
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :attr_name
      f.input :category_id, as: :select, include_blank: false, prompt: "Select category", collection: Category.all.map {|f| [f.category_name, f.id]}
    end
    f.actions
  end

end
