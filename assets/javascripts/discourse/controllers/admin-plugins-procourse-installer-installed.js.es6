import InstallerPlugin from '../models/installer-plugin';

export default Ember.Controller.extend({
  loading: false,
  _init: function() {
    this.set("loading", true);
    InstallerPlugin.findAll().then(result => {
      this.set("plugins", result);
      this.set("loading", false);
    });
  }.on('init'),

  actions: {
    uninstall(pluginName) {
      this.set("uninstalling", true);
      InstallerPlugin.uninstall(pluginName).then(result => {
        this.set("uninstalling", false);
      });
    }
  }

})
