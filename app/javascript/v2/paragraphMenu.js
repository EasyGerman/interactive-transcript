const playElement = $(`
  <button class="playParagraphButton ui tiny icon button">
    <i class="play icon"></i>
  </button>
`);

export default {
  init: () => {
    $('.paragraph-header').prepend(playElement);
    $('.ui.dropdown').dropdown();
  }
}
