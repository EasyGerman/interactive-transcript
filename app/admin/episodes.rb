ActiveAdmin.register EpisodeRecord, as: "Episode" do
  menu priority: 2
  permit_params :access_key, :short_name

  index do
    selectable_column
    id_column
    column :access_key
    column :short_name
    column :podcast
    actions
  end

  show do
    attributes_table do
      row :access_key
      row :data do |episode|
        div style: "max-height: 50em; overflow: auto" do
          JSON.generate episode.data
        end
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  filter :access_key
  filter :short_name
  filter :podcast

  form do |f|
    f.inputs do
      f.input :access_key
      f.input :short_name
    end
    f.actions
  end

end
