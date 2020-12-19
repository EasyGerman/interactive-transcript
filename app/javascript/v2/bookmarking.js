import sidebar from './bookmarking/sidebar';
import recap from './bookmarking/recap';
import { readJSONFromStorage, writeJSONToStorage } from 'v2/utils';
import { createElementFromHTML } from 'v2/utils';
import settingStorage from 'v2/settingStorage';

window.addEventListener('initialize', (event) => {
  if (settingStorage.get('bookmarking') != 'on') return;

  const player = event.detail.player;
  const storageKey = `episode:${window.location.href}:bookmarks`;

  const buttonElement = createElementFromHTML(`
    <div id="bookmark-button" class="ui icon huge white button">
      <i class="align bookmark icon"></i>
    </div>
  `);

  document.querySelector('#main-buttons .right.side-buttons').appendChild(buttonElement);

  buttonElement.addEventListener('click', addBookmark);

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
