module Corrector
  extend self

  def correct_feed_entry_description(html, slug)
    case slug
    when '23-das-deutsche-34737307' then html.sub('[59:4]', '[59:44]')
    when '21-katerstimmung-34308952' then html.sub('[46:35 ', '[46:35] ')
    when '1' then
      html.sub(
        '>Γιάννης Σαρακατσάνης</a></li></ul><p><br></p><br><p><strong>Δημήτρης:</strong></p><p>[0:16] Καλώς ήρθατε και από',
        '>Γιάννης Σαρακατσάνης</a></li></ul><p><br></p><br><h2>Απομαγνητοφώνηση</h2><p><strong>Δημήτρης:</strong></p><p>[0:16] Καλώς ήρθατε και από',
      )
    else html
    end
  end

  def correct_downloadable_transcript_html(html, slug)
    case slug
    when '7-hier-spielt-31687337' then html.sub(%{<br>\n\n<small style="opacity: 0.5;">[14:35]</small>}, %{<br>\n<b data-spk="0" title="">Cari:</b><br>\n<small style="opacity: 0.5;">[14:35]</small>})
    else html
    end
  end
end
