ActiveAdmin.register ProductItem do
  permit_params :sku, :qty_in_stock, :price, :product_id, :variation_option_id, :created_at, :updated_at, product_attributes_attributes: [:id, :attr_value, :attribute_name_id, :product_item_id, :_destroy], product_suppliers_attributes: [:id, :product_item_id, :supplier_id, :_destroy], images_attributes: [:id, :rank, :imageable_type, :imageable_id, :image, :_destroy]
  menu parent: "Product Management", label: 'Product Variation Details'

  index do
    selectable_column
    id_column
    column :sku
    column :qty_in_stock
    column :price
    column :product do |resource|
      product = resource.product
      "#{product.name}"
    end
    column :variation_option do |resource|
      variation_option = resource.variation_option
      "#{variation_option.value}"
    end
    column :created_at
    column :updated_at
    actions
  end

  filter :sku

  show do 
    attributes_table do
      row :sku
      row :qty_in_stock
      row :price
      row :product do |resource|
        product = resource.product
        "#{product.name}"
        end
      row :variation_option do |resource|
        variation_option = resource.variation_option
        "#{variation_option.value}"
        end
      row :created_at
      row :updated_at
    end

    if resource.images.present?
      panel "Images" do
        table_for resource.images do
          column :id
          column :rank
          column :image do |img|
            image_tag url_for(img.image), style: "max-width: 100px; max-height: 100px;" if img.image.attached?
          end
          column :created_at
          column :updated_at
        end
      end
    end

    if resource.product_attributes.present?
      panel "Product Attributes" do
        table_for resource.product_attributes do
          column :id
          column :attribute_name do |resource|
            attribute_name = resource.category_attribute
            "#{attribute_name.attr_name}"
            end
          column :attr_value
          column :created_at
          column :updated_at
        end
      end
    end

    if resource.product_suppliers.present?
      panel "Supplier Info" do
        table_for resource.product_suppliers do
          column :id
          column :name do |resource|
            supplier = resource.supplier
            "#{supplier.name}" if supplier
            end
          column :created_at
          column :updated_at
        end
      end
    end

    if resource.reviews.present?
      panel "Reviews" do
        table_for resource.reviews do
          column :id
          column :email do |resource|
            user = resource.user
            "#{user.email}"
          end
          column :title
          column :description
          column :rating
          column :created_at
          column :updated_at
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :sku
      f.input :qty_in_stock
      f.input :price
      f.input :product_id, as: :select, include_blank: false, prompt: "Select product", collection: Product.all.map {|f| [f.name, f.id]}
      f.input :variation_option_id, as: :select, include_blank: false, prompt: "Select variation option", collection: VariationOption.all.map {|f| [f.value, f.id]}

      f.inputs 'Add Images' do
        f.has_many :images, allow_destroy: true do |a|
          a.input :rank
          a.input :image, as: :file
        end
      end

      f.inputs 'Add Attributes' do
        f.has_many :product_attributes, allow_destroy: true do |a|
          a.input :attr_value
          a.input :attribute_name_id, as: :select, include_blank: false, prompt: "Select attribute", collection: CategoryAttribute.all.map {|f| [f.attr_name, f.id]}
        end
      end

      f.inputs 'Add Supplier Info' do
        f.has_many :product_suppliers, allow_destroy: true do |a|
          a.input :supplier_id, as: :select, include_blank: false, prompt: "Select Supplier", collection: Supplier.all.map {|f| [f.name, f.id]}
        end
      end
    end
    f.actions
  end

end
