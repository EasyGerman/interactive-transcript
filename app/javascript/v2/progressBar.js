function secondsToStringTimestamp(x) {
  var seconds = x % 60;
  if (seconds < 10) { seconds = "0" + seconds }

  var rest = Math.floor(x / 60);
  // if (rest == 0) { return `0:${seconds}` }

  var minutes = rest % 60
  const hours = Math.floor(rest / 60);

  // if (hours == 0) { return `${minutes}:${seconds}` }
  if (minutes < 10) { minutes = "0" + minutes }

  return `${hours}:${minutes}:${seconds}`
}

const init = ({ media }) => {
  const duration = Math.ceil(media.duration);
  $('#total-time').text(secondsToStringTimestamp(duration));

  function updateProgress() {
    const currentTime = Math.round(media.currentTime);

    $('#progress-time').text(secondsToStringTimestamp(currentTime));

    const ratio = currentTime / duration;
    const thickness = 6; // 6px .bar height set in CSS
    const maxWidth = $('#progress-bar').width();
    const w = thickness + (maxWidth - thickness) * ratio;

    $('#progress-bar .bar').css('width', `${w/maxWidth * 100}%`);
  }

  media.addEventListener('timeupdate', updateProgress);
  updateProgress();

  $('#progress-bar-container').click((e) => {
    const maxWidth = $('#progress-bar').width();
    const clickedTime = duration * e.originalEvent.clientX / maxWidth;
    media.currentTime = clickedTime;
  });
}

export default {
  init: init
}
