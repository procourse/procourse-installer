export default Ember.Component.extend({
  classNameBindings: [":logs"],

  _outputChanged: function() {
    Ember.run.scheduleOnce("afterRender", this, "_scrollBottom");
  }.observes("output"),

  _scrollBottom() {
    if (this.get("followOutput")) {
      this.$().scrollTop(this.$()[0].scrollHeight);
    }
  },

  didInsertElement() {
    this._super(...arguments);
    this._scrollBottom();
  }

});
