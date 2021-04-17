import settingStorage from './settingStorage';

const init = (player) => {
  $('#play-button').click(() => {
    if (player.paused) {
      player.play();
    } else {
      player.pause();
    }
  });

  player.media.addEventListener('play', () => {
    $('#play-button > i').removeClass('play').addClass('pause');
  });

  player.media.addEventListener('pause', () => {
    $('#play-button > i').removeClass('pause').addClass('play');
  });

  $('#jump-forward-button').click(() => {
    player.addTime(15);
  });

  $('#jump-backward-button').click(() => {
    player.addTime(-15);
  });

  $('#settings-button > .menu > .speed.item').click((ev) => {
    const $elem = $(ev.target);
    const rate = parseFloat($elem.data('rate'));
    player.media.playbackRate = rate;
    settingStorage.set('playback-rate', rate);
  });
  const savedPlaybackRate = settingStorage.get('playback-rate');
  if (savedPlaybackRate) {
    try {
      player.media.playbackRate = parseFloat(savedPlaybackRate);
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
