RepositoryView = Backbone.View.extend({
  template: _.template('<h3> I am a repository </h3> <p><%= name %></p>'),

  render: function(){
    this.$el.html(this.template(this.model.toJSON()));
    return this;
  }
})
