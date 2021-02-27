const languagePicker = {
  lang: null,
}

$(document).ready(() => {
  const $picker = $('#language-picker')
  languagePicker.lang = localStorage.getItem('language') || 'EN'; // TODO: localize

  $picker.val(languagePicker.lang);
  $('#translation-attribution').text(`Translations by ${$picker.find('option:selected').data('service')}`)

  $picker.change((event) => {
    languagePicker.lang = $picker.val();
    localStorage.setItem('language', languagePicker.lang);
    $('#translation-attribution').text(`Translations by ${$picker.find('option:selected').data('service')}`)
  })
});

export default languagePicker;
