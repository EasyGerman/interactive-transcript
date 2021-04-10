import languagePicker from './languagePicker';
import t from './translations';

const getOrCreateElement = ($paragraph) => {
  // Find element
  let $container = $paragraph.find('.paragraph-main')
  let $el = $container.find('.translation');
  if ($el.length) return $el;

  // Create element
  $container.addClass('with-translation');
  $el = $('<div>').addClass('translation');
  $container.append($el);
  return $el;
}

function showTranslation($paragraph, text, lang) {
  let $translation = getOrCreateElement($paragraph);
  $paragraph.find('.paragraph-content').addClass(`flex-lang flex-${$('#language-picker-form').data('source-lang').toLowerCase()}`)
  $translation.addClass(`flex-lang flex-${lang.toLowerCase()}`);
  $translation.text(text);
  $paragraph.find('.translateParagraphButton').hide();
}

window.addEventListener('paragraph-changed', (ev) => {
  // We're on a new paragraph. If there is a cached translation, we want to show it.
  if (!languagePicker.autoTranslate) return;

  const paragraph = ev.detail.paragraph;
  const $paragraph = paragraph.$element;

  fetchTranslation($paragraph, { fromCache: true }).then(function({ text, lang }) {
    // If the text is missing, it means that it is not cached.
    if (text) {
      showTranslation($paragraph, text, lang);
    }
  }).catch(function() {
    // We can ignore errors when translating automatically
  });
});

function fetchTranslation($paragraph, options = {}) {
  const lang = languagePicker.lang;
  return new Promise((resolve, reject) => {
    $.get({
      url: "/translate.json",
      method: 'post',
      data: {
        key: $paragraph.data('translationId'),
        lang: lang,
        from_cache: options.fromCache // This tells the backend not to call DeepL/Google, but return the translation only if it's cached.
      }
    }).done((resp) => {
      resolve({ text: resp.text, lang });
    }).catch((err) => {
      let jsonr = err.responseJSON;
      console.error("Error while fetching translation:", jsonr)
      let errorMessage = (jsonr && jsonr.error) ? jsonr.error.message : t.translation.error_status
      reject({ err, jsonr, errorMessage });
    });
  })
}

export default {
  init: () => {
    $('.translateParagraphButton').click(function(event) {
      let $button = $(event.target);
      let $buttonContainer = $button.parent();
      let $paragraph = $button.closest('.paragraph');

      $button.prop('disabled', true)
      $button.addClass('loading');
      $button.text(t.translation.loading_status + "...");

      fetchTranslation($paragraph).then(function({ text, lang }) {
        showTranslation($paragraph, text, lang);
      }).catch(function({ err, errorMessage }) {
        $button.text(errorMessage);
      });
    })
  }
}
