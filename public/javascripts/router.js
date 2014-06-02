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
    this.jobs = new Jobs()
    this.repositories.fetch({parse: true});
    this.jobs.fetch({parse: true});
  },


  index: function(){
    console.log('in index');
  },

  repoDetail: function(user, repo){
    var renderRepo = function(model){
      var repoDetailView = new RepositoryDetailView({model: model});
      CIApp.repositoryDetailRegion.show(repoDetailView);
    }

    var renderJob = function(model){
      var jobDetailView = new JobView({model: model});
      CIApp.jobDetailRegion.show(jobDetailView);
    }

    var renderRepoAfterSync = function(context){
      context.listenToOnce(context.repositories, 'sync', function(){
        var model = context.repositories.get(user + '/' + repo)
        renderRepo(model)
      })
    }

    var renderJobAfterSync = function(context){
      context.listenToOnce(context.jobs, 'sync', function(){
        var model = context.jobs.where({github_repo: user + '/' + repo})[0]
        renderJob(model)
      })
    }

    var repoModel = this.repositories.get(user + '/' + repo)
    var jobModel = this.jobs.where({github_repo: user + '/' + repo})[0]

    if(repoModel){
      renderRepo(repoModel)
      renderJob(jobModel)
    }
    else{
      renderRepoAfterSync(this)
      renderJobAfterSync(this)
    }
  }

  //show: function(id){
  //  //show repo
  //}
})
