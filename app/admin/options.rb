ActiveAdmin.register Option do
  permit_params :option_name, :category_id, :created_at, :updated_at, variation_options_attributes: [:id, :value, :option_id, :_destroy]
  menu parent: "Product Management", label: 'Manage Available Options'

  index do
    selectable_column
    id_column
    column :option_name
    column :category do |resource|
      product = resource.category
      "#{product.category_name}"
    end
    column :created_at
    column :updated_at
    actions
  end

  filter :option_name

  show do 
    attributes_table do
      row :option_name
      row :category do |resource|
        product = resource.category
        "#{product.category_name}"
      end
      row :created_at
      row :updated_at
    end

    if resource.variation_options.present?
      panel "Variation Options" do
        table_for resource.variation_options do
          column :id
          column :value
          column :created_at
          column :updated_at
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :option_name
      f.input :category_id, as: :select, include_blank: false, prompt: "Select category", collection: Category.all.map {|f| [f.category_name, f.id]}

      f.inputs 'Variation Options' do
        f.has_many :variation_options, allow_destroy: true do |a|
          a.input :value
        end
      end
    end
    f.actions
  end

end
