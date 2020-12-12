window.addEventListener('initialize', (ev) => {
  $('#info-modal-opener').click((ev) => {
    ev.preventDefault();
    ev.stopPropagation();
    $('#info-modal').show();
  });

  $('#info-modal .close-button').click(() => {
    $('#info-modal').hide();
  });
});
