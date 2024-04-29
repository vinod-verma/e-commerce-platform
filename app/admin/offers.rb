ActiveAdmin.register Offer do
  permit_params :name, :description, :discount, :start_date, :end_date, :created_at, :updated_at
  menu parent: "Manage Offers", label: 'Offers'

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :discount
    column :start_date
    column :end_date
    column :created_at
    column :updated_at
    actions
  end

  filter :name

  show do 
    attributes_table do
      row :name
      row :description
      row :discount
      row :start_date
      row :end_date
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :discount
      f.input :start_date
      f.input :end_date
    end
    f.actions
  end

end
