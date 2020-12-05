const languagePicker = {
  lang: null,
}

$(document).ready(() => {
  const $picker = $('#language-picker')
  languagePicker.lang = localStorage.getItem('language') || 'EN';

  $picker.val(languagePicker.lang);

  $picker.change((event) => {
    languagePicker.lang = $picker.val();
    localStorage.setItem('language', languagePicker.lang);
  })
});

export default languagePicker;
