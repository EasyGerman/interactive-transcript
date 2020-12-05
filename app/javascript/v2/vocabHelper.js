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
  const chapter = chapters.find(({ id, start_time, end_time, has_picture }, index) => {
    return start_time < eventTs && end_time > eventTs;
  });

  if (chapter !== activeChapter) {
    activeChapter = chapter;
    if (chapter && chapter.has_picture) {
      $img.attr('src', ''); // clear the image to avoid transition artifacts when we change 'is-cover'
      setImgSrc($img, chapter.id);
    } else {
      $img.attr('src', coverUrl);
      $img.addClass('is-cover');
    }

    const nextChapter = chapters.find(({ id, start_time, end_time, has_picture }, index) => {
      return start_time > activeChapter.start_time;
    });
    if (nextChapter) {
      setImgSrc($(new Image()), nextChapter.id);
    }
  }
}

export default { init, ontimeupdate };
