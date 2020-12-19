import { findParagraphByTimestamp, findSegmentElementByTimestamp } from 'v2/contentTimestamps';
import { createElementFromHTML } from 'v2/utils';

function placeBookmark(timestamp) {
  const paragraph = findParagraphByTimestamp(timestamp);

  if (!paragraph) {
    console.warn('Tried to bookmark a timestamp that has no paragraph:', timestamp)
    return;
  }

  const bookmarkIconElement = createElementFromHTML(`
    <button class="paragraph-bookmark-icon ui orange tiny icon button" data-timestamp="${timestamp}">
      <i class="bookmark icon"></i>
    </button>
  `)

  bookmarkIconElement.addEventListener('click', handleParagraphBookmarkClick);
  paragraph.bookmarkElement.appendChild(bookmarkIconElement);

  const position = calculateBookmarkIconOffset({ timestamp, paragraph, bookmarkIconElement });
  bookmarkIconElement.style.top = `${position}px`;
}

function calculateBookmarkIconOffset({ timestamp, paragraph, bookmarkIconElement }) {
  const segmentElement = findSegmentElementByTimestamp(timestamp);
  if (segmentElement) {
    return segmentElement.offsetTop - segmentElement.parentElement.offsetTop;
  }
  else {
    return calculateBookmarkIconOffsetByRatio({
      value: timestamp,
      min: paragraph.startTime,
      max: paragraph.endTime,
      containerHeight: paragraph.bookmarkElement.clientHeight,
      iconHeight: bookmarkIconElement.clientHeight,
    });
  }
}

function calculateBookmarkIconOffsetByRatio({ value, min, max, containerHeight, iconHeight }) {
  const usableHeight = containerHeight - iconHeight;
  if (usableHeight <= 0) return 0;
  const ratio = (value - min) / (max - min);
  return usableHeight * ratio;
}

function handleParagraphBookmarkClick(event) {
  window.player.playAt(parseInt(this.dataset['timestamp']));
}


export default { placeBookmark };
