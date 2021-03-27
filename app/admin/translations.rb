ActiveAdmin.register Translation do
  menu priority: 4

  index do
    selectable_column
    id_column
    column :key
    column :translation_cache
    column :source_lang
    column :lang
    column :source_length
    column :translated_at
    actions
  end

  filter :key
  # filter :translation_cache
  filter :source_lang
  filter :lang
  filter :region
  filter :translation_service
  filter :source_length
  filter :body

end
