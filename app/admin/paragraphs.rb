ActiveAdmin.register TranslationCache, as: "Paragraph" do
  menu priority: 3
  permit_params :key, :original

  index do
    selectable_column
    id_column
    column :key
    column :original
    actions
  end

  filter :key
  filter :original
  filter :podcast

  form do |f|
    f.inputs do
      f.input :key
      f.input :original
    end
    f.actions
  end

end
