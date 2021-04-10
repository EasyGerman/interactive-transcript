const languagePicker = {
  lang: null,
  autoTranslate: null,
}

$(document).ready(() => {
  const $picker = $('#language-picker')
  languagePicker.lang = localStorage.getItem('language') || 'EN';

  $picker.val(languagePicker.lang);
  $('#translation-attribution').text(`Translations by ${$picker.find('option:selected').data('service')}`)

  $picker.change((event) => {
    languagePicker.lang = $picker.val();
    localStorage.setItem('language', languagePicker.lang);
    $('#translation-attribution').text(`Translations by ${$picker.find('option:selected').data('service')}`)
  })

  const $checkbox = $('#auto-translate');
  languagePicker.autoTranslate = localStorage.getItem('autoTranslate') == 'true';
  $checkbox.checked = languagePicker.autoTranslate;

  $checkbox.click((event) => {
    languagePicker.autoTranslate = $checkbox.is(':checked');
    localStorage.setItem('autoTranslate', languagePicker.autoTranslate ? 'true' : 'false');
  });

});

export default languagePicker;
