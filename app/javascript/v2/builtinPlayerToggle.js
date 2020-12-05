import settingStorage from './settingStorage';
import layout from './layout';

let $player, $button;

function init(params) {
  $player = $('#builtin-player');
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
  layout.resize();
  settingStorage.set('builtin-player', 'on');
}

function disable() {
  $player.hide();
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
