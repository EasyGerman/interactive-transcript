module Corrector
  extend self

  def correct_feed_entry_description(html, slug)
    case slug
    when '23-das-deutsche-34737307' then html.sub('[59:4]', '[59:44]')
    when '21-katerstimmung-34308952' then html.sub('[46:35 ', '[46:35] ')
    else html
    end
  end

end
