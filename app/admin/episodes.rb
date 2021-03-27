ActiveAdmin.register EpisodeRecord, as: "Episode" do
  menu priority: 2
  permit_params :access_key, :short_name, :data

  index do
    selectable_column
    id_column
    column :access_key
    column :short_name
    column :podcast
    actions
  end

  filter :access_key
  filter :short_name
  filter :podcast

  form do |f|
    f.inputs do
      f.input :access_key
      f.input :short_name
      f.input :data
    end
    f.actions
  end

end
