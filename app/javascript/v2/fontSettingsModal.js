import { changeFontSizeSettingBy } from './layout';

const template = `
<div id="font-settings-modal" class="mini-modal">
  <button class="minus-button blue ui icon button">
    <i class="minus icon"></i>
  </button>

  <button class="plus-button blue ui icon button">
    <i class="plus icon"></i>
  </button>

  <button class="close-button ui icon button">
    <i class="close icon"></i>
  </button>
</div>
`;

$(document).ready(() => {
  init();

  $('#font-settings-opener').click((ev) => {
    show();
  });
});

function init() {
  $('body').append($(template).css('display', 'none'));
  $('#font-settings-modal .close-button').click(() => {
    $('#font-settings-modal').hide();
  });

  $('#font-settings-modal .minus-button').click(() => changeFontSizeSettingBy(-1));
  $('#font-settings-modal .plus-button').click(() => changeFontSizeSettingBy(1));
}

function show() {
  $('#font-settings-modal').show();
}
