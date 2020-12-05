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

    const block = (($elem.height() > $('#content').height()) ? 'start' : 'center');
    $elem.get(0).scrollIntoView({ behavior: 'smooth', block });
  }
}

export default scroller;
