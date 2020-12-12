import settingStorage from './settingStorage';
import layout from './layout';

let $player, $scrubber, $button;

function init(params) {
  $player = $('#builtin-player'); // browser's UI for the <audio> element
  $scrubber = $('#scrubber'); // our own implementation of the progress bar / scrubber
  $button = $('#builtin-player-button');

  $button.click(() => {
    toggle();
    $button.blur();
  });

  if (settingStorage.get('builtin-player') == 'on') {
    enable();
  }
}

function enable() {
  $player.show();
  $scrubber.hide();
  layout.resize();
  settingStorage.set('builtin-player', 'on');
}

function disable() {
  $player.hide();
  $scrubber.show();
  layout.resize();
  settingStorage.set('builtin-player', 'off');
}

function toggle() {
  if ($player.css('display') == 'none') {
    enable();
  } else {
    disable();
  }
}

export default { init }
