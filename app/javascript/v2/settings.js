import settingStorage from 'v2/settingStorage';
import { openInModal } from 'utils/modal';

function open() {
  const modal = openInModal('Settings', `
    <div>
      <h3>Translations</h3>

      <input id="auto_translate" type="checkbox"/>
      <label for="auto_translate">Show translations automatically (if available)</label>

      <h3>Controls</h3>

      <div>
        <input name="controls" type="radio" id="controls_custom_n" value="custom_n">
        <label for="controls_custom_n">Big buttons with simple progress bar</label>
      </div>

      <div>
        <input name="controls" type="radio" id="controls_custom" value="custom">
        <label for="controls_custom">Big buttons with built-in player</label>
      </div>

      <div>
        <input name="controls" type="radio" id="controls_native" value="native">
        <label for="controls_native">Built-in player</label>
      </div>

      <h3>Attributions</h3>

      <p>
        Automated translations are provided by <strong><a href="https://deepl.com" target="_blank">DeepL.com</a></strong>.
      </p>

      <p>
        Icons are provided by <strong><a href="https://fontawesome.com/" target="_blank">Font Awesome</a></strong> under the
        <a href="https://fontawesome.com/license/free" target="_blank">CC BY 4.0 License</a>.
      </p>
    </div>
  `);

  const translationsAutoCheckbox = modal.querySelector('input#auto_translate');
  translationsAutoCheckbox.addEventListener('click', (ev) => {
     settingStorage.setBoolean('auto_translate', translationsAutoCheckbox.checked);
     window.dispatchEvent(new CustomEvent('auto_translate_setting_updated', { detail: { checked: translationsAutoCheckbox.checked } }));
  });
}

export default { open };
