import languagePicker from './languagePicker';

const getOrCreateElement = ($paragraph) => {
  // Find element
  let $container = $paragraph.find('.paragraph-main')
  let $el = $container.find('.translation');
  if ($el.length) return $el;

  // Create element
  $el = $('<div>').addClass('translation');
  $container.append($el);
  return $el;
}

export default {
  init: () => {
    $('.translateParagraphButton').click(function(event) {
      let $button = $(event.target);
      let $buttonContainer = $button.parent();
      let $paragraph = $button.closest('.paragraph');

      let $main = $paragraph.find('.paragraph-main');
      $main.addClass('with-translation');

      $button.prop('disabled', true)
      $button.addClass('loading');
      $button.text('Übersetzung wird geladen...');

      $.get({
        url: "/translate.json",
        method: 'post',
        data: {
          key: $paragraph.data('translationId'),
          lang: languagePicker.lang,
        }
      }).done(function(resp) {
        let $translation = getOrCreateElement($paragraph);
        $translation.text(resp.text)
        $button.hide();
      }).catch(function(err) {
        let jsonr = err.responseJSON;
        console.error("Error while fetching translation:", jsonr)
        let errorMessage = (jsonr && jsonr.error) ? jsonr.error.message : "Übersetzung fehlgeschlagen"
        $button.removeClass('loading').addClass('error');
        $button.text(errorMessage);
      });
    })
  }
}
