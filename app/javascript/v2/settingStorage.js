function get(key) {
  return window.localStorage.getItem(`setting:${key}`);
}

function getInteger(key) {
  const value = get(key);
  if (value) {
    return parseInt(value);
  }
}

function set(key, value) {
  window.localStorage.setItem(`setting:${key}`, value);
}

export default {
  get, getInteger, set
}
