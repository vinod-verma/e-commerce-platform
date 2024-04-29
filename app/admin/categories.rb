ActiveAdmin.register Category do
  permit_params :category_name, :parent_category_id, :created_at, :updated_at, category_attributes_attributes: [:id, :attr_name, :category_id, :_destroy],
  options_attributes: [:id, :option_name, :category_id, :_destroy]
  menu parent: "Product Management", label: 'Manage Categories'

  index do
    selectable_column
    id_column
    column :category_name
    column :parent_category do |resource|
      parent_category = resource.parent_category
      "#{parent_category.category_name}" if parent_category 
    end
    column :created_at
    column :updated_at
    actions
  end

  filter :category_name

  show do 
    attributes_table do
      row :category_name
      row :parent_category do |resource|
        parent_category = resource.parent_category
        "#{parent_category.category_name}" if parent_category 
      end
      row :created_at
      row :updated_at
    end

    if resource.category_attributes.present?
      panel "Attribute Names" do
        table_for resource.category_attributes do
          column :id
          column :attr_name
          column :category do |resource|
            category = resource.category
            "#{category.category_name}"
          end
          column :created_at
          column :updated_at
        end
      end
    end

    if resource.options.present?
      panel "Options" do
        table_for resource.options do
          column :id
          column :option_name
          column :category do |resource|
            category = resource.category
            "#{category.category_name}"
          end
          column :created_at
          column :updated_at
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :category_name
      f.input :parent_category_id, as: :select, include_blank: false, prompt: "Select parent category", collection: Category.all.map {|f| [f.category_name, f.id]}

      f.inputs 'Add Attributes' do
        f.has_many :category_attributes, allow_destroy: true do |a|
          a.input :attr_name
        end
      end

      f.inputs 'Add Options' do
        f.has_many :options, allow_destroy: true do |a|
          a.input :option_name
        end
      end
    end
    f.actions
  end

end
