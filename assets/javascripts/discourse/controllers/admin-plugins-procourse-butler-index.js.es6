import ButlerPlugin from '../models/butler-plugin';

export default Ember.Controller.extend({
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
          this.set("installed", true);
          this.set("installing", false);
        }

        if (msg.value === "complete" || msg.value === "failed") {
          this.updateAttribute("upgrading", false);
          this.set("installing", false);
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
  actions: {
    install() {
      this.set("installing", true);
      this.startBus();
      ButlerPlugin.install(this.get('model').plugin_url);
    }
  }

})
