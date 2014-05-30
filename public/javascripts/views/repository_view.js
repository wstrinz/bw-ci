RepositoryView = Backbone.Marionette.ItemView.extend({
  template: _.template('<h3> I am a repository </h3> <p><%= name %></p>'),
  //tagName: 'li',
  className: 'repository',

 //render: function(){
 //  this.$el.html(this.template(this.model.toJSON()));
 //  return this;
 //}
})
