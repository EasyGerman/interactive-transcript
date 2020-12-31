import settings from 'v2/settings';

const settingsEnabled = window.location.search === '?wip';

window.addEventListener('initialize', (ev) => {
  const button = document.getElementById('settings-opener');

  button.style.display = (settingsEnabled ? 'block' : 'none');

  button.addEventListener('click', settings.open);
});
