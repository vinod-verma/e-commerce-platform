ActiveAdmin.register Manufacturer do
  permit_params :name, :location, :contact_info, :created_at, :updated_at

  index do
    selectable_column
    id_column
    column :name
    column :location
    column :contact_info
    column :created_at
    column :updated_at
    actions
  end

  filter :name

  show do 
    attributes_table do
      row :name
      row :location
      row :contact_info
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :location
      f.input :contact_info
    end
    f.actions
  end

end
