import { secondsToStringTimestamp } from './utils';
import Paragraph from './models/Paragraph';

let timestampElements;

$(document).ready(() => {
  timestampElements = $('.timestamp').toArray().map((x) => [parseInt(x.dataset['timestamp']), x])
});

export function findParagraphByTimestamp(timestamp) {
  const item = timestampElements.find(([t1, e], index) => {
    const nextPair = timestampElements[index + 1];
    const t2 = nextPair ? nextPair[0] : null;
    return timestamp >= t1 && (!t2 || timestamp < t2);
  })
  if (item) {
    const [ts, e] = item;
    const paragraphEl = e.closest('.paragraph');
    return new Paragraph(paragraphEl);
  }
}

export function findSegmentElementByTimestamp(timestamp) {
  const segmentElement = document.querySelector(`span[title="${secondsToStringTimestamp(timestamp)}"]`);
  return segmentElement;
}
