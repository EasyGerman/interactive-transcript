import sidebar from './bookmarking/sidebar';
import recap from './bookmarking/recap';
import { readJSONFromStorage, writeJSONToStorage } from 'v2/utils';

window.addEventListener('initialize', (event) => {
  const player = event.detail.player;
  const storageKey = `episode:${window.location.href}:bookmarks`;

  const $button = $('#bookmark-button');

  $button.click(addBookmark);

  const bookmarks = readJSONFromStorage(storageKey, { items: [] });
  if (bookmarks.items.length > 0) {
    bookmarks.items.forEach(({ t }, index) => {
      sidebar.placeBookmark(t);
    })
    recap.setBookmarks(bookmarks);
  }

  function addBookmark() {
    const timestamp = player.getCurrentSecond();

    let boomarks = readJSONFromStorage(storageKey, { items: [] })
    boomarks.items.push({ t: timestamp });
    readJSONFromStorage(storageKey, boomarks);

    console.log('Bookmarked:', timestamp)

    sidebar.placeBookmark(timestamp);
    recap.setBookmarks(bookmarks);
  }
});
