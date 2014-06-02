RepositoryView = Backbone.Marionette.ItemView.extend({
  template: Handlebars.compile('<a href="{{id}}">{{name}}</a>'),
  tagName: 'li',
  className: 'repository',

  events: {
    'click': 'showRepository'
  },

  showRepository: function(e){
    e.preventDefault();
    //e.preventPropagation();
    CIApp.Router.navigate(this.model.id, {trigger: true});
  }


 //render: function(){
 //  this.$el.html(this.template(this.model.toJSON()));
 //  return this;
 //}
})
