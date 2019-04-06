export default Discourse.Route.extend({
  model() {
    return {"plugin_url": ""};
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});
