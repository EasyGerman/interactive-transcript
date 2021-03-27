ActiveAdmin.register Podcast do
  menu priority: 1
  permit_params :code, :name, :lang, :host, :feed_url, :settings

  index do
    selectable_column
    id_column
    column :code
    column :name
    column :lang
    column :host
    column :feed_url
    actions
  end

  filter :code
  filter :name
  filter :lang
  filter :host

  form do |f|
    f.inputs do
      f.input :code
      f.input :name
      f.input :lang
      f.input :host
      f.input :feed_url
      f.input :settings
    end
    f.actions
  end

end
