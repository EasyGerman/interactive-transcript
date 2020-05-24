$(document).ready(() => {
  const media = document.querySelector('audio');
  const timestampElements = $('.timestamp').toArray().map((x) => [parseInt(x.dataset['timestamp']), x])
  let activeTimestamp = null;
  let activeChapter = null;
  const mode = $('#content').data('mode');
  const chapters = $('#content').data('chapters');
  const accessKey = $('#content').data('accessKey');
  const coverUrl = $('#vocab-helper-img').attr('src');

  function timeupdateNormalMode(e) {
    const eventTs = media.currentTime;
    const item = timestampElements.find(([t1, e], index) => {
      const nextPair = timestampElements[index + 1];
      const t2 = nextPair ? nextPair[0] : null;
      return eventTs >= t1 && (!t2 || eventTs < t2);
    })
    if (item) {
      const [ts, e] = item;
      const elem = $(e).parent();
      if (ts !== activeTimestamp) {
        if (elem.height() > $('#content').height()) {
          elem.get(0).scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
        else {
          elem.get(0).scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        $(".current").removeClass("current");
        $(elem).addClass("current");
        activeTimestamp = ts;
      }
    }
    else {
      $(".current").removeClass("current");
      activeTimestamp = null;
    }
  }

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

  function timeupdateWordMode(e) {
    const eventTs = media.currentTime + 1;
    const intTs = Math.floor(eventTs);

    if (activeTimestamp == intTs) { return; }
    activeTimestamp = intTs;

    const strTs = secondsToStringTimestamp(intTs)

    let $highlighted = $('.word-highlight')
    let $current = $(`span[title="${strTs}"]`)

    if ($current.length > 0) {
      if (!$current.hasClass('word-highlight')) {
        $highlighted.removeClass('word-highlight').addClass('remove-word-highlight')
        $current.removeClass('remove-word-highlight')

        // Make highlighting smoother, so that we don't highlight a bunch of words every second
        $current.each((index, item) => {
          const $item = $(item);
          setTimeout(
            () => { $item.addClass('word-highlight') },
            index * 1000 / $current.length
          )
        })
      }

      $current.get(0).scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }

  function timeupdateForVocabHelper(e) {
    const eventTs = media.currentTime;
    const chapter = chapters.find(({ id, start_time, end_time, has_picture }, index) => {
      return eventTs >= start_time && eventTs < end_time
    });
    if (chapter !== activeChapter) {
      activeChapter = chapter;
      if (chapter && chapter.has_picture) {
        $('#vocab-helper-img').attr('src', `/episodes/${accessKey}/chapters/${chapter.id}/picture.jpg`);
      } else {
        $('#vocab-helper-img').attr('src', coverUrl);
      }
    }
  }

  if (mode === 'word') {
    // Experimental - highlight each word
    $('span').attr('style', null);
    media.addEventListener('timeupdate', timeupdateWordMode);
  } else {
    media.addEventListener('timeupdate', timeupdateNormalMode);
  }

  media.addEventListener('timeupdate', timeupdateForVocabHelper);

  $('.timestamp').parent().addClass('timestampedEntry')

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

  let playButton = $('<button>').addClass("paragraphButton").addClass("playButton").text("Play")
  let translateButton = $('<button>').addClass("paragraphButton").addClass("translateButton").text("Translate");
  $('.timestampedEntry').append(
    $('<div>').addClass('controls').append(playButton).append(translateButton)
  );

  $('.playButton').click(function(event) {
    let timestamp = $(event.target).closest('.timestampedEntry').find('.timestamp');
    if (timestamp.length) {
      media.currentTime = parseInt(timestamp.data('timestamp'));
      media.play();
    }
  });

  $('.translateButton').click(function(event) {
    event.preventDefault();
    event.stopPropagation();
    let $button = $(event.target);
    let $entry = $button.closest('.timestampedEntry');

    $button.html("Translating...");
    $button.attr("disabled", "disabled");

    $.get({
      url: "/translate.json",
      method: 'post',
      data: {
        key: $entry.data('translationId')
      }
    }).done(function(resp) {
      let $translation = $('<p>').addClass('translation').text(resp.text)
      let $controls = $button.closest('.controls')
      $entry.append($translation);
      $button.remove();
    }).catch(function(err) {
      let jsonr = err.responseJSON;
      console.error("Error while fetching translation:", jsonr)
      let errorMessage = jsonr.error ? jsonr.error.message : "Error"
      let $controls = $button.closest('.controls')
      $button.text(errorMessage);
      $button.addClass('error')
    });
  })

  const vocabHelperButtonLabel = $('#vocab-button').text();
  const vocabHelperButtonInverseLabel = $('#vocab-button').data('inverse-label');
  $('#vocab-button').click(() => {
    if ($('#player-page').hasClass('vocab-on')) {
      $('#player-page').removeClass('vocab-on');
      $('#vocab-button').removeClass('on');
    } else {
      $('#player-page').addClass('vocab-on');
      $('#vocab-button').addClass('on');
      // Ensure we scroll to the current position, since scrolling doesn't work while we're in vocab mode
      activeTimestamp = null;
    }
    $('#vocab-button').blur();
  })
});
