import ButlerPlugin from '../models/butler-plugin';

export default Ember.Controller.extend({
  output: null,
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
          this.get("model")
            .filter(repo => repo.get("upgrading"))
            .forEach(repo => {
              repo.set("version", repo.get("latest.version"));
            });
        }

        if (msg.value === "complete" || msg.value === "failed") {
          this.updateAttribute("upgrading", false);
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
      this.startBus();
      ButlerPlugin.install(this.get('model').plugin_url);
    }
  }

})
