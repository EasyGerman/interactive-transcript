const THRESHOLD_IN_SECONDS = 2;
let lastScrolledAt;

const recentlyScrolled = () => (
  lastScrolledAt && lastScrolledAt > performance.now() - THRESHOLD_IN_SECONDS * 1000
);

const scroller = {
  scrollTo: ($elem, options = {}) => {
    if (!options.evenIfRecentlyScrolled) {
      if (recentlyScrolled()) {
        return;
      }
    }
    lastScrolledAt = performance.now();

    const e = $elem.get(0);
    const c = document.getElementById('content');

    // "Position" means the number of pixels between the top of the element and the top of the visible part of the container
    const elemPosition = e.offsetTop - c.offsetTop - c.scrollTop;
    const elemHeight = e.getBoundingClientRect().height;
    const containerHeight = c.clientHeight;

    let desiredElemPosition;

    if (window.transcriptPlayer.wordHighlighting.available) {
      // Strategy 1: minimal scrolling, ideal when individual words are highlighted (otherwise we would scroll to often)

      // const minPosition = 0;                         // Element visible at the very top
      const maxPosition = containerHeight - elemHeight; // Element visible at the very bottom

      const rowHeight = 17; // approximate
      const safetyHeight = rowHeight * 2; // amount of height to be visible before/after highlighted word
      const comfyRatio = 0.2; // fraction of content height to be visible before/after highlighted word if there's a lot of space
      const minSafePosition = Math.max(maxPosition * comfyRatio, safetyHeight);
      const maxSafePosition = maxPosition - minSafePosition;

      if (elemPosition < minSafePosition) {
        // The element is too high
        desiredElemPosition = minSafePosition;
      }
      else if (elemPosition > maxSafePosition) {
        // The element is too low
        desiredElemPosition = minSafePosition;
      }
    }
    else {
      // Strategy 2: always center; ideal when word highlighting is off
      desiredElemPosition = containerHeight / 2;
    }

    if (desiredElemPosition) {
      c.scrollTo({ top: e.offsetTop - c.offsetTop - desiredElemPosition, behavior: 'smooth' })
    }
  }
}


export default scroller;
