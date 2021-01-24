import layout from './layout';
import playerControls from './playerControls';
import wordHighlighter from './word-highlighter';
import scroller from './scroller';
import paragraphMenu from './paragraphMenu';
import translation from './translation';
import vocabHelper from './vocabHelper';
import vocabHelperToggle from './vocabHelperToggle';
import builtinPlayerToggle from './builtinPlayerToggle';
import feedback from './feedback';
import progressBar from './progressBar';
import './infoModal';
import './fontSettingsModal';
import './bookmarking';
import './settingsMenu';
import { findParagraphByTimestamp } from './contentTimestamps';

$(document).ready(() => {
  checkBrowserSuitability().then(initializeApplication);
});

function checkBrowserSuitability(callback) {
  if (document.getElementById('content').scrollTo) {
    return Promise.resolve();
  }
  else {
    $('#loading-container').text("This browser does not support scrolling. Please use a recent version of Chrome or Firefox.");
  }
}

function initializeApplication() {
  const media = document.querySelector('audio');

  const player = {
    media: media,
    pause: () => media.pause(),
    play: () => media.play(),
    playAt: (timestamp) => {
      media.currentTime = timestamp;
      media.play();
    },
    getCurrentSecond: () => Math.floor(media.currentTime),
    get currentTime() { return media.currentTime },
  }

  window.player = player;
  window.dispatchEvent(new CustomEvent('initialize', { detail: { media, player } }));

  layout.init();
  playerControls.init(media);
  paragraphMenu.init();
  translation.init();

  let activeTimestamp = null;
  const mode = $('#content').data('mode');
  const chapters = $('#content').data('chapters');
  const accessKey = $('#content').data('accessKey');

  vocabHelper.init({ media, chapters, accessKey });
  vocabHelperToggle.init();

  builtinPlayerToggle.init();
  feedback.init();
  progressBar.init({ media });

  function timeupdateNormalMode(e) {
    const eventTs = media.currentTime;
    const paragraph = findParagraphByTimestamp(eventTs);

    if (paragraph) {
      const $elem = $(paragraph.element);
      if (paragraph.startTime !== activeTimestamp) {
        const $segment = $elem.find('.segment:first');
        scroller.scrollTo($segment.length ? $segment : $elem, { evenIfRecentlyScrolled: true });
        $(".current").removeClass("current");
        $elem.addClass("current");
        activeTimestamp = paragraph.startTime;
      }
    }
    else {
      $(".current").removeClass("current");
      activeTimestamp = null;
    }
  }

  media.addEventListener('timeupdate', timeupdateNormalMode);
  if (window.transcriptPlayer.wordHighlighting.available) {
    media.addEventListener('timeupdate', wordHighlighter.handleTimeupdate.bind(null, media));
  }
  media.addEventListener('timeupdate', vocabHelper.ontimeupdate);

  $('.timestamp').closest('.paragraph').addClass('timestampedEntry')

  $(window).keypress(function(event) {
    switch (event.key) {
      case " ":
        if (media.paused) {
          media.play();
        }
        else {
          media.pause();
        }
        event.preventDefault();
        break;
    }
  });
  $(window).keydown(function(event) {
    const ev = event.originalEvent;
    let e;
    switch (ev.keyCode) {
      case 37: // left
        media.currentTime -= ev.shiftKey ? 60 : 5;
        event.preventDefault();
        break;
      case 39: // right
        media.currentTime += ev.shiftKey ? 60 : 5;
        event.preventDefault();
        break;
      case 38: // up
        e = $('.current').prevAll('.timestampedEntry').get(0);
        if (e) {
          media.currentTime = parseInt($(e).find('.timestamp').data('timestamp'))
          event.preventDefault();
        }
        break;
      case 40: // down
        e = $('.current').nextAll('.timestampedEntry').get(0);
          if (e) {
          media.currentTime = parseInt($(e).find('.timestamp').data('timestamp'))
          event.preventDefault();
        }
        break;
    }
  });

  $('.playParagraphButton').click(function(event) {
    let timestamp = $(event.target).closest('.paragraph').find('.timestamp');
    if (timestamp.length) {
      media.currentTime = parseInt(timestamp.data('timestamp'));
      media.play();
    }
  });

  function hashChanged(hash) {
    const match = hash.match(/^#((\d{1,2}):)?(\d{1,2}):(\d{2})$/)
    if (match) {
      const [_x, _y, h, m, s] = match;
      const seconds = (parseInt(h) || 0) * 3600 + parseInt(m) * 60 + parseInt(s)
      console.log('jumping to', seconds, h, m, s)
      media.currentTime = seconds;
      media.play();
    }
  }
  if (window.location.hash && window.location.hash.length) {
    hashChanged(window.location.hash);
  }
  if ("onhashchange" in window) { // event supported?
    window.onhashchange = function () {
      hashChanged(window.location.hash);
    }
  }
  else { // event not supported:
    var storedHash = window.location.hash;
    window.setInterval(function () {
      if (window.location.hash != storedHash) {
        storedHash = window.location.hash;
        hashChanged(storedHash);
      }
    }, 1000);
  }

  document.getElementById('player-page').style.visibility = 'visible';
  document.getElementById('loading').style.display = 'none';

};
