CIApp = new Backbone.Marionette.Application({
 //start: function(){
 //  Backbone.history.start({pushState: true})
 //},
});

CIApp.addRegions({
  mainRegion: '#app'
})

CIApp.addInitializer(function(options){
  var reposView = new RepositoriesView({
    collection: options.repos
  });
  CIApp.mainRegion.show(reposView);
});

CIApp.Router = Backbone.Marionette.AppRouter.extend({
 //routes: {'': 'index'},

 //initialize: function(){
 //  this.repositories = new Repositories();
 //  this.reposView = new RepositoriesView({collection: this.repositories});
 //  this.reposView.render()
 //},


 //index: function(){
 //  console.log('in index')
 //  this.repositories.fetch({parse: true})
 //  $('#app').html(this.reposView.el)
 //},

 //show: function(id){
 //  //show repo
 //}
})
