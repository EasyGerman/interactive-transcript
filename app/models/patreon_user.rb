class PatreonUser < ApplicationRecord

  ADMIN_USERS = %w[
    https://www.patreon.com/leventebagi
    https://www.patreon.com/easygerman
  ]

  def name
    user_data['full_name']
  end

  def url
    user_data['url']
  end

  def admin?
    url.in?(ADMIN_USERS)
  end

  def has_access_to?(podcast)
    admin?
  end

end
