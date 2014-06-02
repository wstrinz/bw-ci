CIApp = new Backbone.Marionette.Application({
 //start: function(){
 //  Backbone.history.start({pushState: true})
 //},
});

CIApp.addRegions({
  repositoryDetailRegion: '#repository-detail',
  jobDetailRegion: '#job-detail',
  reposListRegion: '#sidebar'
})

CIApp.addInitializer(function(options){
  CIApp.Router = new CIRouter(options);
});

CIApp.addInitializer(function(options){
  var reposView = new RepositoriesView({
    collection: options.repos
  });
  CIApp.reposListRegion.show(reposView);
});

CIApp.addInitializer(function(options){
  Backbone.history.start({pushState: true})
});

CIApp.addInitializer(function(options){
  this.repositories.fetch({parse: true});
});

var CIRouter = Backbone.Marionette.AppRouter.extend({
 routes: {
   '': 'index',
   ':user/:repo': 'repoDetail'
 },

 initialize: function(options){
   this.repositories = options.repos;
 },


 index: function(){
   console.log('in index');
 },

 repoDetail: function(user, repo){
   console.log('repodetail')
   var repoDetailView = new RepositoryDetailView({model: new Repository({id: 'user/repo', name: 'repo'})});
   var jobDetailView = new JobView({model: new Job({id: 'JeninksID', job_name: 'A job name'})});
   CIApp.repositoryDetailRegion.show(repoDetailView);
   CIApp.jobDetailRegion.show(jobDetailView);
 }

 //show: function(id){
 //  //show repo
 //}
})
