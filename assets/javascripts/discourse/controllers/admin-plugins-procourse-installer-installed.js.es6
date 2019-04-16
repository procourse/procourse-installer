import InstallerPlugin from '../models/installer-plugin';

export default Ember.Controller.extend({
  loading: false,
  output: null,
  percent: "0",
  messageReceived(msg) {
    switch (msg.type) {
      case "log":
        this.set("output", this.get("output") + msg.value + "\n");
        break;
      case "percent":
        this.set("percent", msg.value);
        break;
      case "status":
        this.set("status", msg.value);

        if (msg.value === "complete") {
          this.set("uninstalled", true);
          this.set("uninstalling", false);
        }

        if (msg.value === "complete" || msg.value === "failed") {
          this.stopBus();
        }

        break;
    }
  },

  startBus() {
    MessageBus.subscribe("/docker/upgrade", msg => {
      this.messageReceived(msg);
    });
  },

  stopBus() {
    MessageBus.unsubscribe("/docker/upgrade");
  },
  _init: function() {
    this.set("loading", true);
    InstallerPlugin.findAll().then(result => {
      this.set("plugins", result);
      this.set("loading", false);
    });
  }.on('init'),

  actions: {
    uninstall(pluginName) {
      bootbox.confirm(
        I18n.t("admin.procourse-installer.remove.modal", { plugin_name: pluginName }),
        I18n.t("no_value"),
        I18n.t("yes_value"),
        result => {
          if (result) {
            this.set("uninstalling", true);
            this.set("output", "");
            this.set("uninstalled", false);
            this.startBus();
            InstallerPlugin.uninstall(pluginName);
          }
        }
      );
    }
  }

})
