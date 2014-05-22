//CIApp = new Backbone.Marionette.Application();

CIApp = new (Backbone.Router.extend({
  routes: {'': 'index'},

  initialize: function(){
    this.repositories = new Repositories();
    this.reposView = new RepositoriesView({collection: this.repositories});
    this.reposView.render()
  },

  start: function(){
    Backbone.history.start({pushState: true})
  },

  index: function(){
    console.log('in index')
    this.repositories.fetch({parse: true})
    $('#app').html(this.reposView.el)
  },

  show: function(id){
    //show repo
  }
}))
