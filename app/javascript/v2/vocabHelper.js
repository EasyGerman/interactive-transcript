let $img, media, chapters, accessKey, coverUrl;
let activeChapter = null;

function init(params) {
  media = params.media;
  chapters = params.chapters;
  accessKey = params.accessKey;
  $img = $('#vocab-helper-img');
  coverUrl = $img.attr('src');
}

function setImgSrc($img, chapterId) {
  $img.off('error');
  // TODO: multi-podcast: dynamic URL format
  const primaryURL = `https://easygermanpodcastplayer-public.s3.eu-central-1.amazonaws.com/vocab/${accessKey}/${chapterId}.jpg`;
  const fallbackURL = `/episodes/${accessKey}/chapters/${chapterId}/picture.jpg`
  $img.attr('src', primaryURL);
  $img.on('error', (e, a) => {
    console.warn("Error loading image from primary location");
    $img.off('error');
    $img.attr('src', fallbackURL);
  });
  $img.removeClass('is-cover');
}

function ontimeupdate(e) {
  const eventTs = media.currentTime;

  // Find the current chapter
  const chapter = chapters.find(({ id, start_time, end_time, has_picture }, index) => {
    return start_time <= eventTs && end_time > eventTs;
  });

  // If we just entered a new chapter
  if (chapter !== activeChapter) {
    console.log('Chapter changed:', chapter);
    activeChapter = chapter;

    if (chapter && chapter.has_picture) {
      // Show a vocab helper slide
      $img.attr('src', ''); // clear the image to avoid transition artifacts when we change 'is-cover'
      setImgSrc($img, chapter.id);
    } else {
      // Show podcast cover
      $img.attr('src', coverUrl);
      $img.addClass('is-cover');
    }

    // Preload next vocab helper
    const nextChapter = chapters.find(({ id, start_time, end_time, has_picture }, index) => {
      // If there's no current chapter => select the first chapter that has a picture;
      // otherwise select the one that comes after the current chapter.
      return (activeChapter ? start_time > activeChapter.start_time : true) && has_picture;
    });
    if (nextChapter) {
      setImgSrc($(new Image()), nextChapter.id);
    }
  }
}

export default { init, ontimeupdate };
