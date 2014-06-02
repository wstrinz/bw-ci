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

var CIRouter = Backbone.Marionette.AppRouter.extend({
  routes: {
    '': 'index',
    ':user/:repo': 'repoDetail'
  },

  initialize: function(options){
    this.repositories = options.repos;
    this.repositories.fetch({parse: true});
  },


  index: function(){
    console.log('in index');
  },

  repoDetail: function(user, repo){
    var doRender = function(model){
      repoDetailView = new RepositoryDetailView({model: model});
      var jobDetailView = new JobView({model: new Job({id: 'JeninksID', job_name: 'A job name'})});
      CIApp.repositoryDetailRegion.show(repoDetailView);
      CIApp.jobDetailRegion.show(jobDetailView);
    }

    var renderAfterSync = function(context){
      context.listenToOnce(context.repositories, 'sync', function(){
        var model = context.repositories.get(user + '/' + repo)
        doRender(model)
      })
    }

    var model = this.repositories.get(user + '/' + repo)
    if(model)
      doRender(model)
    else
      renderAfterSync(this)
  }

  //show: function(id){
  //  //show repo
  //}
})
