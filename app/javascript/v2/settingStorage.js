function get(key) {
  return window.localStorage.getItem(`setting:${key}`);
}

function set(key, value) {
  window.localStorage.setItem(`setting:${key}`, value);
}

function getInteger(key) {
  const value = get(key);
  if (value) {
    return parseInt(value);
  }
}

function setBoolean(key, value) {
  set(key, value ? 'on' : 'off');
}

function getBoolean(key) {
  const value = get(key);
  if (value === 'on') return true;
  else if (value === 'off') return false;
}

export default {
  get, set,
  getInteger,
  getBoolean, setBoolean
}
