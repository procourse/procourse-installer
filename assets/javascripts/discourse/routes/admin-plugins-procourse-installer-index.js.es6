import DiscourseRoute from "discourse/routes/discourse";

export default DiscourseRoute.extend({
  model() {
    return {"plugin_url": ""};
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});
