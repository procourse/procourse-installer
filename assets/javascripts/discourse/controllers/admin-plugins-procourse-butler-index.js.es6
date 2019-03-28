import ButlerPlugin from '../models/butler-plugin';

export default Ember.Controller.extend({
  actions: {
    install() {
      ButlerPlugin.install(this.get('model').plugin_url);
    }
  }

})
