function readJSON(key, defaultValue = {}) {
  let item = window.localStorage.getItem(key);
  if (!item) return defaultValue;
  try {
    return JSON.parse(item);
  } catch (SyntaxError) {
    return defaultValue;
  }
}
function writeJSON(key, value) {
  window.localStorage.setItem(key, JSON.stringify(value));
}

window.addEventListener('initialize', (event) => {
  const player = event.detail.player;
  const storageKey = `episode:${window.location.href}:bookmarks`;

  const $button = $('#bookmark-button');

  $button.click(addBookmark);

  function addBookmark() {
    const timestamp = player.getCurrentSecond();

    let boomarks = readJSON(storageKey, { items: [] })
    boomarks.items.push({ t: timestamp });
    writeJSON(storageKey, boomarks);

    console.log('Bookmarked:', timestamp)
  }
});
