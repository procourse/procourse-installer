import { default as discourseComputed } from 'discourse-common/utils/decorators';

export default Ember.Component.extend({
  classNameBindings: [":progress", ":progress-striped", "active"],

  @discourseComputed("percent")
  active(percent) {
    return parseInt(percent, 10) !== 100;
  },

  @discourseComputed("percent")
  progress(percent) {
    return parseInt(percent, 10);
  }

});
