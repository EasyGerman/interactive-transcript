const THRESHOLD_IN_SECONDS = 2;
let lastScrolledAt;

const recentlyScrolled = () => (
  lastScrolledAt && lastScrolledAt > performance.now() - THRESHOLD_IN_SECONDS * 1000
);

const isAtStartOfTheLine = ($elem) => (
  !!$elem.toArray().find((e) => $(e).position().left <= 40)
);

const scroller = {
  scrollTo: ($elem, options = {}) => {
    if (!options.evenIfRecentlyScrolled) {
      if (!isAtStartOfTheLine($elem) || recentlyScrolled()) {
        return;
      }
    }
    lastScrolledAt = performance.now();

    const block = (($elem.height() > $('#content').height() || $('#content').height() < 300) ? 'start' : 'center');
    $elem.get(0).scrollIntoView({ behavior: 'smooth', block });
  }
}

export default scroller;
