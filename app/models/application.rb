module Application
  module_function

  %w[easygerman easygreek].each do |code|
    define_method code do
      Podcast.find_by!(code: code)
    end
  end
end
