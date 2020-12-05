export default {
  get: (key) => {
    return window.localStorage.getItem(`setting:${key}`);
  },
  set: (key, value) => {
    window.localStorage.setItem(`setting:${key}`, value);
  }
}
