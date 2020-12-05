import scroller from 'v2/scroller';

const WORD_HIGHLIGHT_START_AHEAD_IN_SECONDS = 1;

let lastHighlightedTs = null;

function secondsToStringTimestamp(x) {
  var seconds = x % 60;
  if (seconds < 10) { seconds = "0" + seconds }

  var rest = Math.floor(x / 60);
  if (rest == 0) { return `0:${seconds}` }

  var minutes = rest % 60
  const hours = Math.floor(rest / 60);

  if (hours == 0) { return `${minutes}:${seconds}` }
  if (minutes < 10) { minutes = "0" + minutes }

  return `${hours}:${minutes}:${seconds}`
}

function addClassSmoothlyToMultipleElements(className, $elem, callback) {
  // Make highlighting smoother, so that we don't highlight a bunch of words every second
  $elem.each((index, item) => {
    const $item = $(item);
    setTimeout(
      () => {
        $item.addClass(className);
        if (callback) {
          callback($item);
        }
      },
      index * 1000 / $elem.length
    )
  })
}

function handleTimeupdate(media, e) {
  const eventTs = media.currentTime + WORD_HIGHLIGHT_START_AHEAD_IN_SECONDS;
  const highlightTs = Math.floor(eventTs);

  if (lastHighlightedTs == highlightTs) { return; }

  // Remove highlight when seeking
  if (Math.abs(lastHighlightedTs - highlightTs) > 2) {
    $('.word-highlight').removeClass('word-highlight')
    $('.remove-word-highlight').remove('remove-word-highlight')
  }

  lastHighlightedTs = highlightTs;

  const strTs = secondsToStringTimestamp(highlightTs)

  let $highlighted = $('.word-highlight')
  let $current = $(`span[title="${strTs}"]`)

  if ($current.length > 0) {
    if (!$current.hasClass('word-highlight')) {
      $current.removeClass('remove-word-highlight')

      addClassSmoothlyToMultipleElements('word-highlight', $current, ($item) => {
        scroller.scrollTo($item);
      })
    }
  }

  let $old = $(`span[title="${secondsToStringTimestamp(highlightTs - 1)}"]`)
  if ($old.length > 0)  {
    addClassSmoothlyToMultipleElements('remove-word-highlight', $old)
  }
}

export default {
  handleTimeupdate: handleTimeupdate
}
