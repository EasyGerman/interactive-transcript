export default class Paragraph {
  constructor(element) {
    this.element = element;
    this.$element = $(element);
    this.timestampElement = element.getElementsByClassName('timestamp')[0];
  }

  get next() {
    const sibling = this.element.nextElementSibling;
    if (sibling) {
      return new Paragraph(sibling);
    } else {
      return null;
    }
  }

  get startTime() {
    return parseInt(this.timestampElement.dataset['timestamp']);
  }

  get endTime() {
    if (!window.player) throw new Error('Cannot determine endTime because the player has not been initialized');
    return this.next ? this.next.startTime : window.player.media.duration;
  }

  get bookmarkElement() {
    return this.element.getElementsByClassName('paragraph-bookmarks')[0];
  }

  get translationId() {
    return this.element.dataset.translationId;
  }
}
