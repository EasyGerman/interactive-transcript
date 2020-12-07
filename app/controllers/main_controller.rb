class MainController < ApplicationController
  def show
    redirect_to current_podcast.membership_url || current_podcast.homepage_url
  end
end
