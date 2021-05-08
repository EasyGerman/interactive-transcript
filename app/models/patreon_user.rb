class PatreonUser < ApplicationRecord

  extend Memoist

  PLEDGES_STALE_AFTER = 1.day

  ADMIN_USERS = %w[
    https://www.patreon.com/leventebagi
    https://www.patreon.com/easygerman
  ]

  class Error < StandardError; end

  delegate :access_token, :fresh_access_token, to: :oauth_adapter

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
    return true if admin?

    # Does this podcast has a Patreon configuration?
    if podcast.patreon_minimum_pledge.blank?
      Rails.logger.debug "patreon_minimum_pledge blank"
      return false
    end

    # Does this user have a subscription for this podcast?
    pledge = pledge_for(podcast)
    return false if pledge.blank?

    (pledge.amount_cents >= podcast.patreon_minimum_pledge).tap do |result|
      if result == false
        Rails.logger.debug "PatreonUser #{id} pledge amount does not give access to podcast - pledge.amount_cents=#{pledge.amount_cents.inspect} podcast.patreon_minimum_pledge=#{podcast.patreon_minimum_pledge.inspect}"
      end
    end
  end

  def pledges
    return [] if user_data.blank? || user_data["pledges"].blank?
    user_data.fetch("pledges").map { |raw_pledge| Pledge.new(raw_pledge) }
  end

  def pledge_for(podcast)
    if podcast.patreon_creator_id.blank?
      Rails.logger.debug "patreon_creator_id blank"
      return
    end

    sync_pledges_if_stale

    raw_pledge = user_data["pledges"]&.find { |pledge| pledge.fetch('creator_id') == podcast.patreon_creator_id.to_s }

    if raw_pledge.blank?
      Rails.logger.debug "PatreonUser #{id} does not have a subscription for #{podcast.name} patreon_creator_id=#{podcast.patreon_creator_id.inspect}"
      return
    end

    Pledge.new(raw_pledge)
  end

  def sync_pledges_if_stale
    return if last_synced_at >= PLEDGES_STALE_AFTER.ago
    sync_pledges
  end

  def sync_pledges
    Rails.logger.info "Syncing pledges for PatreonUser #{id}"
    user_response = Patreon::API.new(fresh_access_token).fetch_user
    import_user_data_from_patreon_response(user_response)
    save!
  end

  def import_user_data_from_patreon_response(user_response)
    known_creator_ids = Podcast.all.map(&:patreon_creator_id)

    self.user_data = {
      pledges: user_response.data.pledges.select { |pledge| pledge.creator.id.in?(known_creator_ids) }.map { |pledge|
        {
          creator_id: pledge.creator.id,
          amount_cents: pledge.amount_cents,
        }
      }
    }
    self.last_synced_at = Time.current
    save!
  end

  memoize def oauth_adapter
    PatreonOauthAdapter.new(self)
  end


  class Pledge < CustomStruct
    attribute :creator_id, Types::String
    attribute :amount_cents, Types::Integer
  end

end
