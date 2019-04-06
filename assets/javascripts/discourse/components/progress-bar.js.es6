import { observes, on } from 'ember-addons/ember-computed-decorators';
import computed from 'ember-addons/ember-computed-decorators';

export default Ember.Component.extend({
  classNameBindings: [":progress", ":progress-striped", "active"],

  @computed("percent")
  active(percent) {
    return parseInt(percent, 10) !== 100;
  },

  @computed("percent")
  progress(percent) {
    return parseInt(percent, 10);
  }

});
