import settingStorage from './settingStorage';

const init = (media) => {
  $('#play-button').click(() => {
    if (media.paused) {
      media.play();
    } else {
      media.pause();
    }
  });

  media.addEventListener('play', () => {
    $('#play-button > i').removeClass('play').addClass('pause');
  });

  media.addEventListener('pause', () => {
    $('#play-button > i').removeClass('pause').addClass('play');
  });

  $('#jump-forward-button').click(() => {
    media.currentTime += 15;
  });

  $('#jump-backward-button').click(() => {
    media.currentTime -= 15;
  });

  $('#settings-button > .menu > .speed.item').click((ev) => {
    const $elem = $(ev.target);
    const rate = parseFloat($elem.data('rate'));
    media.playbackRate = rate;
    settingStorage.set('playback-rate', rate);
  });
  const savedPlaybackRate = settingStorage.get('playback-rate');
  if (savedPlaybackRate) {
    try {
      media.playbackRate = parseFloat(savedPlaybackRate);
    }
    catch (e) {
      console.error("Exception while trying to set playbackRate from savedPlaybackRate:", e)
    }
  }

  $('.ui.dropdown').dropdown();
  $('#speed-button').click(() => {
    $('#speed-button .ui.modal').modal('show');
  });
}

export default {
  init: init
}
