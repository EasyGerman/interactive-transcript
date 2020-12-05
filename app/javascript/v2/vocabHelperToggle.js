import settingStorage from './settingStorage';

let $playerPage, $button;

function init() {
  $playerPage = $('#player-page');
  $button = $('#vocab-button');

  $button.click(() => {
    toggle()
    $button.blur();
  });

  if (settingStorage.get('vocab-helper') == 'on') {
    enable();
  }
}

function enable() {
  $playerPage.addClass('vocab-on');
  $button.addClass('on');
  settingStorage.set('vocab-helper', 'on');
  // Ensure we scroll to the current position, since scrolling doesn't work while we're in vocab mode
  // activeTimestamp = null;
  window.dispatchEvent(new Event('vocabToggle'));
}

function disable() {
  $playerPage.removeClass('vocab-on');
  $button.removeClass('on');
  settingStorage.set('vocab-helper', 'off');
  window.dispatchEvent(new Event('vocabToggle'));
}

function toggle() {
  if ($playerPage.hasClass('vocab-on')) {
    disable();
  } else {
    enable();
  }
}

export default { init }
