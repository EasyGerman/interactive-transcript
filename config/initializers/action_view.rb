%w{render_partial render_collection}.each do |event|
  ActiveSupport::Notifications.unsubscribe "#{event}.action_view"
end
