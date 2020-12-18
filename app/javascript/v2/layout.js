import settingStorage from './settingStorage';

function init() {
  window.addEventListener("resize", resize);
  window.addEventListener("vocabToggle", resize);
  resize();
}

const vocabDefaultSize = 400;
const vocabHeightRatio = 0.85; // the ratio of the height compared to the width if we cut off the logo from the bottom
const contentMaxWidth = 900;
let fontSizeSetting = settingStorage.getInteger('font-size');

function setFontSize() {
  // Set font size
  const referenceSize = Math.min(window.innerWidth, window.innerHeight);
  window.fontSize = fontSizeSetting || (referenceSize >= 400 ? 16 : (referenceSize >= 360 ? 15 : (referenceSize >= 300 ? 14 : 13)))
  document.getElementsByTagName('body')[0].style.fontSize = `${Math.round(window.fontSize)}px`;
}

export function changeFontSizeSettingBy(delta) {
  fontSizeSetting = (fontSizeSetting || window.fontSize) + delta;
  settingStorage.set('font-size', fontSizeSetting)
  resize();
}

function resize() {
  setFontSize();
  setPlayerControlButtonSize(window.innerWidth);
  const playerHeight = document.getElementById('player-controls').clientHeight;
  const landscape = window.innerWidth >= window.innerHeight;
  const vocabOn = $('#player-page').hasClass('vocab-on');

  const bound = { w: window.innerWidth, h: window.innerHeight - playerHeight };

  const main = document.getElementById('player-page');
  const content = document.getElementById('content');

  const vocab = landscape ? calculateVocabSizeLandscape(bound) : calculateVocabSizePortrait(bound);

  if (landscape) {
    main.style.gridTemplateRows = `[w-top c-top] 1fr [c-bottom] auto [w-bottom]`;
    if (vocabOn) {
      // === Vocab visible ===
      if (bound.w >= vocabDefaultSize * 2 + contentMaxWidth) {
        // Very wide - room for full-width transacript + full-width vocab on both sides (so that the transcript can stay in the center)
        main.style.gridTemplateColumns = `[w-left] 1fr ${vocab.w}px [c-left] ${contentMaxWidth}px ${vocab.w}px 1fr [c-right w-right]`;
      } else if (bound.w >= vocabDefaultSize + contentMaxWidth) {
        // Wide - room for full-width vocab + transcript
        main.style.gridTemplateColumns = `[w-left] 1fr ${vocab.w}px [c-left] ${contentMaxWidth}px 1fr [c-right w-right]`;
      } else {
        main.style.gridTemplateColumns = `[w-left] ${vocab.w}px [c-left] 1fr [c-right w-right]`;
      }
    } else {
      // === Vocab not visible ===
      if (bound.w >= contentMaxWidth) {
        main.style.gridTemplateColumns = `[w-left] 1fr [c-left] ${contentMaxWidth}px 1fr [c-right w-right]`;
      }
      else {
        main.style.gridTemplateColumns = `[w-left c-left] 1fr [c-right w-right]`;
      }
    }
  } else {
    if (bound.w >= contentMaxWidth) {
      main.style.gridTemplateColumns = `[w-left] 1fr [c-left] ${contentMaxWidth}px 1fr [c-right w-right]`;
    } else {
      main.style.gridTemplateColumns = `[w-left c-left] 1fr [c-right w-right]`;
    }
    if (vocabOn) {
      main.style.gridTemplateRows = `[w-top] ${vocab.h}px [c-top] 1fr [c-bottom] ${playerHeight}px [w-bottom]`;
    } else {
      main.style.gridTemplateRows = `[w-top c-top] 1fr [c-bottom] ${playerHeight}px [w-bottom]`;
    }
  }
  content.style.height = `${bound.h - (!landscape && vocabOn ? vocab.h : 0)}px` // for Safari


  setVocabSize(vocab);
}

function calculateVocabSizeFromFontSize() {
  // Ratio: 22 - this way the text on the vocab helper looks just slightly bigger than the transcript font
  return window.fontSize * 22;
}

function calculateVocabSizeLandscape(bound) {
  const w = Math.min(calculateVocabSizeFromFontSize(), bound.h / vocabHeightRatio, bound.w / 2, vocabDefaultSize)
  const h = bound.h >= w ? w : w * vocabHeightRatio; // if there's enough room, keep the full height, otherwise cut off the logo
  return { w: Math.round(w), h: Math.round(h) }
}

function calculateVocabSizePortrait(bound) {
  const w = Math.min(calculateVocabSizeFromFontSize(), bound.h / 5 * 3, bound.w, vocabDefaultSize);
  const h = bound.h > 2 * w ? w : w * vocabHeightRatio; // cut off logo if the device is not very tall
  return { w: Math.round(w), h: Math.round(h) }
}

function setVocabSize(vocab) {
  const img = document.getElementById('vocab-helper-img')
  img.style.width = `${vocab.w}px`;
  img.style.height = `${vocab.h}px`;
}

let previousSize = 'huge';
const setPlayerControlButtonSize = (width) => {
  const newSize = calculatePlayerControlButtonSize(width);
  if (newSize === previousSize) return;
  $('#player-controls .side-buttons .button').removeClass('massive huge big large medium small tiny mini').addClass(newSize);
  previousSize = newSize;
}
const calculatePlayerControlButtonSize = (width) => {
  if (width <= 338) return 'medium';
  if (width <= 370) return 'large';
  if (width <= 390) return 'big';
  if (width <= 430) return 'huge';
  return 'massive';
}

export default {
  init: init,
  resize: resize,
  changeFontSizeSettingBy: changeFontSizeSettingBy,
}
