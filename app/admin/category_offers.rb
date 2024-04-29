ActiveAdmin.register CategoryOffer do
  permit_params :category_id, :offer_id, :created_at, :updated_at
  menu parent: "Manage Offers", label: 'Manage Category Wise Offers'

  index do
    selectable_column
    id_column
    column :category do |resource|
      category = resource.category
      "#{category.category_name}"
    end
    column :offer do |resource|
      offer = resource.offer
      "#{offer.name}"
    end
    column :created_at
    column :updated_at
    actions
  end

  show do 
    attributes_table do
      row :category do |resource|
        category = resource.category
        "#{category.category_name}"
      end
      row :offer do |resource|
        offer = resource.offer
        "#{offer.name}"
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :category_id, as: :select, include_blank: false, prompt: "Select Category", collection: Category.all.map {|f| [f.category_name, f.id]}
      f.input :offer_id, as: :select, include_blank: false, prompt: "Select Offer", collection: Offer.all.map {|f| [f.name, f.id]}
    end
    f.actions
  end

end
