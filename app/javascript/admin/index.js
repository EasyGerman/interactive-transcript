let timeout = null;

$(() => {
  const media = document.querySelector('audio');
  const $media = $(media);

  $('.timestamp-object').click((ev) => {
    if (timeout) clearTimeout(timeout);
    $media.stop();

    const timestamp = parseFloat(ev.target.dataset.timestamp);

    media.currentTime = timestamp;
    media.volume = 1;
    media.play();

    timeout = setTimeout(() => {
      $media.animate({ volume: 0 }, 2000, () => {
        media.pause();
        timeout = setTimeout(() => {
          media.volume = 1;
        }, 100);
      });
    }, 1000);
  });
});
