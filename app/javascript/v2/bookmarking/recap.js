import { createElementFromHTML } from 'v2/utils';
import settingStorage from 'v2/settingStorage';

const playWindowDuration = 5; // seconds
const fadeInDuration = 2;
const fadeOutDuration = 2;
const minJumpDuration = fadeInDuration + fadeOutDuration + 5; // seconds; keep playing instead of jumping if the next bookmark is less than this amount away

let initialized = false;
let bookmarkItems;
let currentIndex;
let timeout;
let triggerTime;


function init() {
  if (settingStorage.get('bookmarking:recap') != 'on') return;
  if (initialized) return;
  initialized = true;

  const recapButton = createElementFromHTML(`
    <button class="recap-button ui orange tiny icon button">
      <i class="bookmark icon"></i>
    </button>
  `);
  recapButton.addEventListener('click', handleRecapClick);
  document.getElementById('pre-play').appendChild(recapButton);

  window.player.media.addEventListener('timeupdate', handleTimeUpdate);
  // window.player.media.addEventListener('seeking', () => {
  //   // pause recap
  //   console.log("seeking - recap interrupted")
  //   triggerTime = null;
  // });
}

function setBookmarks(argBookmarks) {
  init();
  // WARNING: sorts IN-PLACE
  if (!argBookmarks.items) return;
  bookmarkItems = argBookmarks.items.sort((a, b) => a.t - b.t);
  // console.log('bookmarkItems', bookmarkItems)
}

function handleRecapClick() {
  console.log('bookmarkItems', bookmarkItems)
  if (!bookmarkItems || bookmarkItems.length == 0) {
    console.warn("Cannot start recap, there are no bookmarks.");
    return;
  }

  jumpTo(0);
}

function jumpTo(index) {
  currentIndex = index;
  const { t } = bookmarkItems[index];
  console.log('jump to', index, t);

  if (t - fadeInDuration <= 0) {
    window.player.playAt(t - fadeInDuration);
  }
  else {
    window.player.media.volume = 0;
    window.player.playAt(t - fadeInDuration);
    $(window.player.media).animate({ volume: 1 }, fadeInDuration * 1000);
  }

  console.log(performance.now(), 'scheduling timeout');
  triggerTime = t + playWindowDuration;
  console.log('next triggerTime:', triggerTime, `bookmarkTime: ${t}`);
}

function handleTimeUpdate() {
  if (!triggerTime) return;
  const currentTime = window.player.media.currentTime;
  console.log('t', currentTime);
  if (currentTime > triggerTime) {
    triggerTime = null;
    continueRecap();
  }
}


function continueRecap() {
  // console.log(performance.now(), 'continueRecap');
  let i = currentIndex;
  let didJump;
  while (true) {
    i++;
    if (!bookmarkItems[i]) {
      // No more bookmarks, end of recap
      $(window.player.media).animate({ volume: 0 }, fadeOutDuration * 1000, () => {
        window.player.media.volume = 1;
        window.player.pause();
      });
      break;
    };
    didJump = jumpCarefully(i)
    if (didJump) break;
  }
}

function jumpCarefully(index) {
  const { t } = bookmarkItems[index];
  const currentTime = window.player.currentTime;
  console.log(`checking bookmark[${index}] bookmarkTime=${t} currentTime=${currentTime}`);
  if (currentTime >= t + playWindowDuration) {
    // We've already played this bookmark (probably a duplicate bookmark)
    console.log('location already played, no jump');
    return false;
  } else if (currentTime + minJumpDuration >= t) {
    // We've already played part of this bookmark (currentTime >= t)
    // or the jump would be too short
    // Continue playing, set timeout for the remaining part.
    const remainingSeconds = t + playWindowDuration - currentTime;
    currentIndex = index;
    triggerTime = t + playWindowDuration;
    console.log('next triggerTime:', triggerTime, `bookmarkTime: ${t} - extended`);
    return true;
  } else {
    $(window.player.media).animate({ volume: 0 }, fadeOutDuration * 1000, () => {
      window.player.media.volume = 1;
      jumpTo(index);
    });
    return true;
  }
}

export default { setBookmarks };
