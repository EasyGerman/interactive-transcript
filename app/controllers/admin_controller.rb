class AdminController < ApplicationController
  http_basic_authenticate_with name: "admin", password: ENV.fetch('ADMIN_PASSWORD', SecureRandom.hex(64))

  layout "admin"
end
