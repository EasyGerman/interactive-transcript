export function createElementFromHTML(htmlString) {
  var div = document.createElement('div');
  div.innerHTML = htmlString.trim();
  return div.firstChild;
}

export function secondsToStringTimestamp(x) {
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

export function readJSONFromStorage(key, defaultValue = {}) {
  let item = window.localStorage.getItem(key);
  if (!item) return defaultValue;
  try {
    return JSON.parse(item);
  } catch (SyntaxError) {
    return defaultValue;
  }
}

export function writeJSONToStorage(key, value) {
  window.localStorage.setItem(key, JSON.stringify(value));
}
